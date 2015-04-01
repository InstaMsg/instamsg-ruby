autoload 'Logger', 'logger'
require 'uri'
require 'forwardable'
require 'instamsg/client'
# Used for configuring API credentials and creating client objects
#
module Instamsg

class Error < RuntimeError; end
class AuthenticationError < Error; end
class ConfigurationError < Error; end
class HTTPError < Error; attr_accessor :original_error; end
class << self

extend Forwardable
def_delegators :default_client, :scheme, :host, :port, :key, :secret, :http_proxy, :bearer_token
def_delegators :default_client, :scheme=, :host=, :port=, :key=, :secret=, :http_proxy=, :bearer_token=
def_delegators :default_client, :bearer_token, :access_token, :url
def_delegators :default_client, :encrypted=, :url=
def_delegators :default_client, :timeout=, :connect_timeout=, :send_timeout=, :receive_timeout=, :keep_alive_timeout=
def_delegators :default_client, :get, :get_async, :post, :post_async, :authenticate

attr_writer :logger
def logger
@logger ||= begin
log = Logger.new($stdout)
log.level = Logger::INFO
log
end
end
def default_client
@default_client ||= Instamsg::Client.new
end
end
if ENV['INSTAMSG_URL']
self.url = ENV['INSTAMSG_URL']
end
end
require 'instamsg/request'
require 'instamsg/resource'
