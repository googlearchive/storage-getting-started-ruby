require "gcloud/storage"
require "highline/import"

# Constants for use as request parameters.
PROJECT = ENV["PUBSUB_PROJECT"] || "YOUR_PROJECT_ID"
KEYFILE = ENV["PUBSUB_KEYFILE"] || "./client_secrets.json"

storage = Gcloud.storage PROJECT, KEYFILE

file_menu = lambda do |file|
  loop do
    choose do |menu|
      menu.header = "You are viewing file #{file.name}"

      menu.choice("List Access Control Lists for #{file.name}") do
        say "ACLs for #{file.name} are:"
        say "* Owners: #{file.acl.owners.join(", ")}"
        say "* Writers: #{file.acl.writers.join(", ")}"
        say "* Readers: #{file.acl.readers.join(", ")}"
      end

      menu.choice("Display file details") do
        say "Details for #{file.name}:"
        say "* name: #{file.name}"
        say "* size: #{file.size}"
        say "* url: #{file.url}"
        say "* etag: #{file.etag}"
        say "* md5: #{file.md5}"
        say "* crc32c: #{file.crc32c}"
      end

      menu.choices("Back to bucket") { return }
    end
  end
end

bucket_menu = lambda do |bucket|
  loop do
    choose do |menu|
      menu.header = "You are viewing bucket #{bucket.name}"

      menu.choice("List Access Control Lists for #{bucket.name}") do
        say "ACLs for #{bucket.name} are:"
        say "* Owners: #{bucket.acl.owners.join(", ")}"
        say "* Writers: #{bucket.acl.writers.join(", ")}"
        say "* Readers: #{bucket.acl.readers.join(", ")}"
      end

      menu.choice("List Default Access Control Lists for #{bucket.name}") do
        say "Default ACLs for #{bucket.name} are:"
        say "* Owners: #{bucket.default_acl.owners.join(", ")}"
        say "* Writers: #{bucket.default_acl.writers.join(", ")}"
        say "* Readers: #{bucket.default_acl.readers.join(", ")}"
      end

      menu.choice("List all files for #{bucket.name}") do
        say "Files for #{bucket.name} are:"
        bucket.files.each { |file| say file.name }
      end

      menu.choice("Inspect a file") do
        file_name = ask "Which file do you want to inspect?"
        file = bucket.find_file file_name
        if file.nil?
          say "Sorry, but #{file_name} does not exist in #{bucket.name}."
        else
          file_menu.call file
        end
      end

      menu.choices("Back to project") { return }
    end
  end
end

loop do
  choose do |menu|
    menu.header = "You are viewing the storage for project #{storage.project}"

    menu.choice("List all buckets for #{storage.project}") do
      say "Buckets for #{storage.project} are:"
      storage.buckets.each { |bucket| say "* #{bucket.name}" }
    end

    menu.choice("Inspect a bucket") do
      bucket_name = ask "Which bucket do you want to inspect?"
      begin
        bucket = storage.find_bucket bucket_name
        if bucket.nil?
          say "Sorry, but #{bucket_name} does not exist."
        else
          bucket_menu.call bucket
        end
      rescue Gcloud::Storage::Error => e
        say "Unable to load bucket #{bucket_name}. Recieved the error: #{e}"
      end
    end

    menu.choices("Exit") { exit }
  end
end
