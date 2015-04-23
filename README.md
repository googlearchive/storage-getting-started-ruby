# Google Cloud Storage Ruby Sample Application

## Description
This is a simple command line example of calling the Google Cloud Storage
APIs in Ruby.

## Prerequisites
Please make sure that all of the following is installed before trying to run
the sample application.

- Ruby 1.9.3+
- The following gems (run 'sudo gem install <gem name>' to install)
  * gcloud
  * highline
- If you haven't installed the above gems, try this:
  * 'sudo gem install gcloud highline'

## Setup Authentication
1) Visit https://console.developers.google.com/project to register your application.
- From the "Project Home" screen, activate access to "Google Cloud Storage
API".
- Click on "Credentials" under "APIs & Auth" in the left column
- Click the button labeled "Create new Client ID"
- Choose "Service account" under "Application type" and "JSON key" under "Key type" and click "Create Client ID"
- Copy the downloaded file to this directory and rename it to "client_secrets.json"

2) Update sample.rb with all default settings. Search and replace all strings
that begin with 'YOUR_' with their associated values.

## Running the Sample Application
1. Run the application
  * $ ruby sample.rb
2. The Google Cloud Storage sample application will display its output on the
command line.
