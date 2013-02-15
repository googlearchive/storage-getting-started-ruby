require 'rubygems'
require 'google/api_client'
require 'yaml'
require 'base64'
require 'json'


PROJECTID = '514219538978'
BUCKET = '15ruby-api-test'
METADATA_OBJECT = 'metadata_obj'
MEDIA_OBJECT = 'media_obj'
RESUMABLE_OBJECT = 'resumable_obj'
MULTIPART_OBJECT = 'multipart_obj'
TEXT_FILE = 'sample.txt'

# Setup authorization
oauth_yaml = YAML.load_file('.google-api.yaml')
client = Google::APIClient.new(application_name: "", application_version: "")
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

if client.authorization.refresh_token && client.authorization.expired?
  client.authorization.fetch_access_token!
end


# Create client
storage = client.discovered_api('storage', 'v1beta1')

# Get a specific object from a bucket
bucket_get_result = client.execute(
  api_method: storage.objects.get,
  parameters: {bucket: BUCKET, object: METADATA_OBJECT}
)
puts "\nContents of #{METADATA_OBJECT} in #{BUCKET}: "
puts bucket_get_result.body


# List all buckets in the project
bucket_list_result = client.execute(
  api_method: storage.buckets.list,
  parameters: {projectId: PROJECTID}
)
puts "\n\nList of buckets: "
puts bucket_list_result.data.items.map(&:id)


=begin
# Create a bucket in the project
bucket_insert_result = client.execute(
  api_method: storage.buckets.insert,
  parameters: {},
  body_object: {id: BUCKET, projectId: PROJECTID}
)
p bucket_insert_result.data
contents = bucket_insert_result.data
puts "\n\nCreated bucket #{contents.id} at #{contents.selfLink}"
=end

# Insert a small object into a bucket using metadata
media = Google::APIClient::UploadIO.new(TEXT_FILE, 'text/plain')
object_content = 'Insert content here.'
metadata_insert_result = client.execute(
  api_method: storage.objects.insert,
  parameters: {
    uploadType: 'media', 
    bucket: BUCKET, 
    name: METADATA_OBJECT
  },
  body_object: {
    contentType: 'text/plain', 
    data: Base64.encode64(object_content)
  }
)
contents = metadata_insert_result.data
puts "Metadata insert: #{contents.name} at #{contents.selfLink}"


# Simple "media" upload - CURRENTLY BROKEN
=begin
media = Google::APIClient::UploadIO.new(TEXT_FILE, 'text/plain')
media_insert_result = client.execute(
  api_method: storage.objects.insert,
  parameters: {uploadType: 'media', 
    bucket: BUCKET, 
    name: MEDIA_OBJECT
  },
  media: media
)
puts object_insert_result.body
=end


# Multipart upload
media = Google::APIClient::UploadIO.new(TEXT_FILE, 'text/plain')
multipart_insert_result = client.execute(
  api_method: storage.objects.insert,
  parameters: {
    uploadType: 'multipart', 
    bucket: BUCKET, 
    name: MULTIPART_OBJECT
  },
  body_object: {contentType: 'text/plain'},
  media: media
)
contents = multipart_insert_result.data
puts "Multipart insert:\n#{contents.name} at #{contents.selfLink}"


# Resumable upload
resumable_media = Google::APIClient::UploadIO.new(TEXT_FILE, 'text/plain')
metadata = {
 contentType: 'text/plain'
}
resumable_result = client.execute(
  api_method: storage.objects.insert,
  media: resumable_media,
  parameters: {
    uploadType: 'resumable',
    bucket: BUCKET,
    name: RESUMABLE_OBJECT
  },
  body_object: metadata
)
# Does actual upload of file
upload = resumable_result.resumable_upload
if upload.resumable?
  client.execute(upload)
end
puts "\nResumable insert: "
puts "Created object #{upload.parameters['name']}"



# List all objects in a bucket
objects_list_result = client.execute(
  api_method: storage.objects.list,
  parameters: {bucket: BUCKET}
)
puts "\nList of objects in #{BUCKET}: "
objects_list_result.data.items.each { |item| puts item.name }


# Get a specific object from a bucket
bucket_get_result = client.execute(
  api_method: storage.objects.get,
  parameters: {bucket: BUCKET, object: METADATA_OBJECT}
)
puts "\nContents of #{METADATA_OBJECT} in #{BUCKET}: "
puts bucket_get_result.body


# Delete object from bucket
object_delete_result = client.execute(
  api_method: storage.objects.delete,
  parameters: {bucket:BUCKET, object: RESUMABLE_OBJECT}
)
puts "\nDeleting #{RESUMABLE_OBJECT}: "
p object_delete_result.headers


# Insert object acl
object_acl_insert_result = client.execute(
  api_method: storage.object_access_controls.insert,
  parameters: {bucket: BUCKET, object: METADATA_OBJECT},
  body_object: {entity: 'allUsers', role: 'READER'}
)
puts "\nInserting object ACL: #{object_acl_insert_result.body}"


# Get object acl
object_acl_get_result = client.execute(
  api_method: storage.object_access_controls.get,
  parameters: {bucket: BUCKET, object: METADATA_OBJECT, entity: 'allUsers'}
)
puts "\nGet object ACL: "
contents = object_acl_get_result.data
entity = contents.entity
role = contents.role
puts "Users #{entity} can access #{METADATA_OBJECT} as #{role}"


# Delete a bucket in the project
bucket_delete_result = client.execute(
  api_method: storage.buckets.delete,
  parameters: {bucket: BUCKET}
)
puts "\nDeleting #{BUCKET}: #{bucket_delete_result.body}"

