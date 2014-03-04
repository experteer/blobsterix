#!/usr/bin/env ruby

require 'net/http'

uri = URI.parse("http://localhost:9000/blob/v1/rotate_25,ascii_250.images/expired.pngd")

# Net::HTTP.start("localhost", 9000) do |http|
#     resp = http.get("/images/syncview21force.png")
#     open("/home/dsudmann/desktop/syncview21force.png", "wb") do |file|
#         file.write(resp.body)
#     end
# end

# Net::HTTP.start(uri.host,uri.port) do |http|
#     resp = http.get(uri.path)
#     open("/home/dsudmann/desktop/syncview21force.png", "wb") do |file|
#         file.write(resp.body)
#     end
# end

Net::HTTP.start(uri.host,uri.port) do |http|
  open("/home/dsudmann/desktop/syncview21force", "wb") do |file|
    http.request_get(uri.path){ |resp|
      puts resp.code
      resp.read_body{ |seg|
        file << seg
      }
    }
  end
end