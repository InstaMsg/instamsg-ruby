require 'openssl'
module Instamsg
  class Request
    attr_reader :body, :params

    def initialize(client, verb, uri, token, params, body = nil)
      @client, @verb, @uri = client, verb, uri
      @head = {}
      @body = body
      if @body
        @head['Content-Type'] = 'application/json'
      end
      @head['Authorization'] = token
      @params = params
    end

    def send_sync
      http = @client.http_sync_client
      http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        response = http.request(@verb, @uri, @params, @body, @head)
      rescue HTTPClient::BadResponseError, HTTPClient::TimeoutError,
          SocketError, HTTPClient::ReceiveTimeoutError, Errno::ECONNREFUSED => e
        error = Instamsg::HTTPError.new("#{e.message} (#{e.class})")
        error.original_error = e
        
        raise error
      end
      body = response.body ? response.body.chomp : nil
      return handle_response(response.code.to_i, body)
    end

    def send_async
      if defined?(EventMachine) && EventMachine.reactor_running?
        http_client = @client.http_async_client(@uri)
        deferrable = EM::DefaultDeferrable.new

        http = case @verb
        when :post
          http_client.post({
              :query => @params, :body => @body, :head => @head
            })
        when :get
          http_client.get({
              :query => @params, :head => @head
            })
        when :put
          http_client.put({
              :query => @params, :body => @body, :head => @head
            })
        when :delete
          http_client.delete({
              :query => @params, :head => @head
            })
        else
          raise "Unsupported verb"
        end
        
        http.callback {
          begin
            deferrable.succeed(handle_response(http.response_header.status, http.response.chomp))
          rescue => e
            deferrable.fail(e)
          end
        }
        
        http.errback { |e|
          message = "Instamsg connection error : (#{http.error})"
          Instamsg.logger.debug(message)
          deferrable.fail(Error.new(message))
        }
        

        return deferrable
      else
        http = @client.sync_http_client
        return http.request_async(@verb, @uri, @params, @body, @head)
      end
    end
    
    def download_em_http(urls, concurrency)
      EventMachine.run do
        multi = EventMachine::MultiRequest.new
 
        EM::Iterator.new(urls, concurrency).each do |url, iterator|
          req = EventMachine::HttpRequest.new(url).get
          req.callback do
            write_file url, req.response
            iterator.next
          end
          multi.add url, req
          multi.callback { EventMachine.stop } if url == urls.last
        end
      end
    end 
    
    def upload_sync
      http = @client.http_sync_client
      http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        File.open(@params["file"]) do |file|
          @body = { :file => file}
          response = http.request(@verb, @uri, @params, @body, @head)
          
          body = response.body ? response.body.chomp : nil
          return handle_response(response.code.to_i, body)
        end
      rescue HTTPClient::BadResponseError, HTTPClient::TimeoutError,
          SocketError, HTTPClient::ReceiveTimeoutError, Errno::ECONNREFUSED => e
        error = Instamsg::HTTPError.new("#{e.message} (#{e.class})")
        error.original_error = e
        raise error
      end
    end

    private

    def handle_response(status_code, body)
      case status_code
      when 200
        return body
      when 202
        return true
      when 400
        raise Error, "Bad request: #{body}"
      when 401
        raise AuthenticationError, body
      when 403
        raise Error, "#{body}"
      when 404
        raise Error, "404 Not found (#{@uri.path})"
      when 407
        raise Error, "Proxy Authentication Required"
      else
        raise Error, "Unknown error (status code #{status_code}): #{body}"
      end
    end

  end
end
