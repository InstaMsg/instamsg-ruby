# instamsg-ruby
This is a ruby library for InstaMsg Rest api.

### Installation & Configuration

Add instamsg-ruby to your Gemfile, and then run bundle install

`gem 'instamsg-ruby'`

or install via gem

`gem install instamsg-ruby`

After registering at https://platform.instamsg.io/signup configure your app with the security credentials.
You can find instamsg starting quick guide here. (http://instamsg.io/docs/quick-start)


### Instantiating a InstaMsg client
 
  For add instamsg in your app add `require 'instamsg'` in your controller or helper.

  `instamsg =  Instamsg::Client.new({
        :host => 'platform.instamsg.io',
        :port => 443,
        :bearer_token => "gt0AF51x7wxHFUNX44FPYCWPRhU5icDrPKA02GKR22jwt6jkrnTC3TZbTjs",
        :key=> '5cf46a16-cde6-4ece-9005-0c6f26fa71a0',
        :secret=> '468a08a5-5e18-4aa6-8692-c367bcbf3944'
      })`
      
  Where key and secret is your registerd app key and secret. For getting bearer(access) token you have to authenticate first.
  This client have all the functionality provided by InstaMsg api.
  
###   Create an InstaMsg account & get API Keys

[create an Instamsg account](https://platform.instamsg.io/signup) and [follow these steps to get](http://instamsg.io/docs/quick-start) your  _`client_id`_ & _`client_secret`_ .

###   Authenticating your credentials

Currently we are supporting only one grant type.
Path for getting your bearer token "oauth2/token" and grant_type is "client_credentials"

`instamsg.authenticate(path,params)`

Example : 
 
 Request is : 
 
`instamsg.authenticate("/oauth2/token",{:grant_type => "client_credentials"})`
 
 Response is : 
 
`{
  "access_token": "gt0AF51x7wxHFUNX44FPYCWPRhU5icDrPKA02GKR22jwt6jkrnTC3TZbTjs",
  "token_type": "bearer",
  "expires_in": 31536000000
}`

###   Requests to InstaMsg Rest api

You can get, post, put and delete your resources. We are supporting sync and async request both.

##    For Sync Request

`instamsg.get(path,params)`

`instamsg.post(path,params)`

`instamsg.put(path,params)`

`instamsg.delete(path,params)`


##    For Async Request

`instamsg.get_async(path,params)`

`instamsg.post_async(path,params)`

`instamsg.put_async(path,params)`

For detailed InstaMsg Rest api methods you can visit. (http://instamsg.io/docs/api)

###   Handle File Operations

You can get files list from a connected client. You can upload and download files to a connected client. <\br>
File operations are sync operations.

Download all file

`instamsg.get("/api/beta/tenants/tenant_id/clients/client_id}/files", params)`

Upload a file

`instamsg.put_file("/api/beta/tenants/tenant_id/clients/client_id}/files", {:file => file_path})`

Download a file

`instamsg.get_file("/api/beta/tenants/tenant_id/clients/client_id}/files/file_name", params)`

This gives you a hhttp file url in response. And then you can download this file from that url.

You can find all client api methods here. (http://instamsg.io/docs/client)


###   Handling Exceptions & Errors

````javascript
begin
    instamsg.get(path,params)
rescue Instamsg::Error => e
    (Instamsg::AuthenticationError, Instamsg::HTTPError, or Instamsg::Error)
end
 ````

