require 'httpclient'
require "base64"

module Instamsg
  class Client
    attr_accessor :scheme, :host, :port, :key, :secret, :bearer_token
    attr_reader :http_proxy, :proxy
    attr_writer :connect_timeout, :send_timeout, :response_timeout,
      :keep_alive_timeout

    def initialize(options = {})
      default = {
        :scheme => 'https',
        :host => 'platform.instamsg.io',
        :port => 443,
      }.merge(options)
      @scheme, @host, @port, @key, @secret, @bearer_token  = default.values_at(
        :scheme, :host, :port, :key, :secret, :bearer_token
      )

      @http_proxy = nil
      self.http_proxy = default[:http_proxy] if default[:http_proxy]

      @connect_timeout = 15
      @send_timeout = 100
      @response_timeout = 180
      @keep_alive_timeout = 180
    end
    
    def url(path = nil)
      URI::Generic.build({
          :scheme => @scheme,
          :host => @host,
          :port => @port,
          :path => "#{path}"
        })
    end
    
    def access_token
      @access_token ||= "Basic " + Base64.encode64(@key + ":" + @secret).delete("\n")
    end
    
    def bearer_token
      "Bearer " + @bearer_token
    end

    def url=(url)
      uri = URI.parse(url)
      @scheme = uri.scheme
      @key    = uri.user
      @secret = uri.password
      @host   = uri.host
      @port   = uri.port
    end

    def http_proxy=(http_proxy)
      @http_proxy = http_proxy
      uri = URI.parse(http_proxy)
      @proxy = {
        :scheme => uri.scheme,
        :host => uri.host,
        :port => uri.port,
        :user => uri.user,
        :password => uri.password
      }
      @http_proxy
    end

    def encrypted=(boolean)
      @scheme = boolean ? 'https' : 'http'
      @port = boolean ? 8601 : 8600
    end

    def encrypted?
      @scheme == 'https'
    end

    def timeout=(value)
      @connect_timeout, @send_timeout, @response_timeout = value, value, value
    end
    
    def resource(path)
      Resource.new(self, path)
    end
    
    def authenticate(path, params = {})
      Resource.new(self, path).authenticate(params)
    end
    
    def invalidate(path, params = {})
      Resource.new(self, path).authenticate(params)
    end

    def get(path, params = {})
      Resource.new(self, path).get(params)
    end

    def get_async(path, params = {})
      Resource.new(self, path).get_async(params)
    end

    def post(path, params = {})
      Resource.new(self, path).post(params)
    end

    def post_async(path, params = {})
      Resource.new(self, path).post_async(params)
    end

    def put(path, params = {})
      Resource.new(self, path).put(params)
    end
    
    def put_async(path, params = {})
      Resource.new(self, path).put_async(params)
    end
     
    def delete(path, params = {})
      Resource.new(self, path).delete(params)
    end
    
    def delete_async(path, params = {})
      Resource.new(self, path).delete_aysnc(params)
    end
    
    def get_file(path, params= {})
      Resource.new(self, path).download(params)
    end
    
    def put_file(path, params= {})
      Resource.new(self, path).upload(params)
    end
    
    def http_sync_client
      @client ||= begin
        HTTPClient.new(@http_proxy).tap do |c|
          c.connect_timeout = @connect_timeout
          c.send_timeout = @send_timeout
          c.receive_timeout = @response_timeout
          c.keep_alive_timeout = @keep_alive_timeout
        end
      end
    end

    def http_async_client(uri)
      begin
        unless defined?(EventMachine) && EventMachine.reactor_running?
          raise Error, "Must use event machine for async request."
        end
        require 'em-http' unless defined?(EventMachine::HttpRequest)

        conn_options = {
          :connect_timeout => @connect_timeout,
          :inactivity_timeout => @response_timeout,
        }

        if defined?(@proxy)
          proxy_options = {
            :host => @proxy[:host],
            :port => @proxy[:port]
          }
          if @proxy[:user]
            proxy_options[:authorization] = [@proxy[:user], @proxy[:password]]
          end
          conn_options[:proxy] = proxy_options
        end

        EventMachine::HttpRequest.new(uri, conn_options)
      end
    end

  end
end
