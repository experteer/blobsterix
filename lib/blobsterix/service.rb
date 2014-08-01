module Blobsterix
  class Service < Goliath::API
    use Goliath::Rack::Params
    include Logable
=begin
    def on_headers(env, headers)
      env.logger.info 'received headers: ' + headers.inspect
        env['async-headers'] = headers
    end

    def on_body(env, data)
      env.logger.info 'received data: ' + data
      (env['async-body'] ||= '') << data
    end

    def on_close(env)
      env.logger.info 'closing connection'
    end
=end
    def get_request_id
      @request_id||=0
      @request_id+=1
    end
    def response(env)
      env["BLOBSTERIX_REQUEST_ID"] = get_request_id
      logger.info "RAM USAGE Before[#{Process.pid}]: " + `pmap #{Process.pid} | tail -1`[10,40].strip
      a = call_stack(env, BlobApi, StatusApi, S3Api)
      logger.info "RAM USAGE After[#{Process.pid}]: " + `pmap #{Process.pid} | tail -1`[10,40].strip
      a
    end

    def call_stack(env, *apis)
      last_answer = [404,{}, ""]
      apis.each do |api|
        last_answer = api.call(env)
        if last_answer[0] != 600
          return last_answer
        end
      end
      last_answer[0] != 600 ? last_answer : [404,{}, ""]
    end
  end
end
