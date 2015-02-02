require 'google/api_client'
require 'highline/import'
require './oauth_util'

# Constants for use as request parameters.
API_VERSION = 'v1'
DEFAULT_PROJECT = 'YOUR_PROJECT_ID'
DEFAULT_BUCKET = 'YOUR_DEFAULT_BUCKET'
DEFAULT_OBJECT = 'YOUR_DEFAULT_OBJECT'
DEFAULT_ENTITY = 'YOUR_DEFAULT_ENTITY'

# Creating a new API client and loading the Google Cloud Storage API.
client = Google::APIClient.new
storage = client.discovered_api('storage', API_VERSION)

# OAuth authentication.
auth_util = CommandLineOAuthHelper.new(
  'https://www.googleapis.com/auth/devstorage.full_control')
client.authorization = auth_util.authorize()

# Linking each input selection to an API request.
api_request_selection_map = {
  '1' => storage.buckets.list,
  '2' => storage.objects.list,
  '3' => storage.bucket_access_controls.list,
  '4' => storage.object_access_controls.list,
  '5' => storage.buckets.get,
  '6' => storage.objects.get,
  '7' => storage.bucket_access_controls.get,
  '8' => storage.object_access_controls.get
}

# Linking each API request to appropriate request parameters.
api_request_parameter_map = {
  storage.buckets.list => {
    'project' => DEFAULT_PROJECT
  },
  storage.objects.list => {
    'bucket' => DEFAULT_BUCKET
  },
  storage.bucket_access_controls.list => {
    'bucket' => DEFAULT_BUCKET
  },
  storage.object_access_controls.list => {
    'bucket' => DEFAULT_BUCKET,
    'object' => DEFAULT_OBJECT
  },
  storage.buckets.get => {
    'bucket' => DEFAULT_BUCKET
  },
  storage.objects.get => {
    'bucket' => DEFAULT_BUCKET,
    'object' => DEFAULT_OBJECT
  },
  storage.bucket_access_controls.get => {
    'bucket' => DEFAULT_BUCKET,
    'entity' => DEFAULT_ENTITY
  },
  storage.object_access_controls.get => {
    'bucket' => DEFAULT_BUCKET,
    'object' => DEFAULT_OBJECT,
    'entity' => DEFAULT_ENTITY
  }
}

# Linking each API request to an appropriate request body.
api_request_body_map = {
}

# REPL style interface for making API requests.
while true
  print "[1] List Buckets \n"
  print "[2] List Objects \n"
  print "[3] List Bucket Access Control Lists \n"
  print "[4] List Object Access Control Lists \n"
  print "[5] Get Bucket \n"
  print "[6] Get Object \n"
  print "[7] Get Bucket Access Control List \n"
  print "[8] Get Object Access Control List \n"
  print "Press any other key to exit \n"
  print "\n"
  api_selection = ask "Please select an API request from the above list. \n"
  case api_selection
  when '1'..'8'
    api_request = api_request_selection_map[api_selection]

    # Executing the selected API request, passing along an appropriate set of
    # request parameters and a request body.
    result = nil
    if api_request_body_map[api_request]
      result = client.execute(
        :api_method => api_request,
        :parameters => api_request_parameter_map[api_request],
        :body_object => api_request_body_map[api_request]
      )
    else
      result = client.execute(
        :api_method => api_request,
        :parameters => api_request_parameter_map[api_request]
      )
    end

    print result.body
  else
    print 'Not a valid selection, please run program again and select a valid' +
    " API request. \n"
    exit
  end
end
