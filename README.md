# Google Cloud Storage Ruby Sample Application

## Description
This is a simple command line example of calling the Google Cloud Storage
APIs in Ruby.

## Prerequisites
Please make sure that all of the following is installed before trying to run
the sample application.

- Ruby 1.9.3+
- The following gems (run 'sudo gem install <gem name>' to install)
  * google-api-client
  * thin
  * launchy
  * highline
- If you haven't installed the above gems, try this:
  * 'sudo gem install google-api-client thin launchy highline'
- The google-api-ruby-client library checked out locally, and this sample
application running from inside of that repo.

## Setup Authentication
1) Visit https://code.google.com/apis/console/ to register your application.
- From the "Project Home" screen, activate access to "Google Cloud Storage
API".
- Click on "API Access" in the left column
- Click the button labeled "Create an OAuth 2.0 client ID"
- Give your application a name and click "Next"
- Select "Installed Application" as the "Application type"
- Select "Other" under "Installed application type"
- Click "Create client ID"

2) Run 'cp client_secrets.json.sample client_secrets.json'
- Edit the client_secrets.json file and enter the client ID and secret that
you retrieved from the API Console.

3) Update sample.rb with all default settings. Search and replace all strings
that begin with 'YOUR_' with their associated values.

## Running the Sample Application
1. Run the application
  * $ ruby sample.rb
2. Authorize the application in the browser window that opens.
3. The Google Cloud Storage sample application will display its output on the
command line.
