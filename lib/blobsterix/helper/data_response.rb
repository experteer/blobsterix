module Blobsterix
  module Http
    class DataResponse
      attr_reader :meta, :with_data, :etag, :env

      def initialize(_meta, _with_data = true, _etag = nil, _env = nil)
        @meta = _meta
        @with_data = _with_data
        @etag = _etag
        @env = _env
      end

      def call
        if !meta.valid
          Http.NotFound()
        elsif Blobsterix.use_x_send_file && etag != meta.etag
          [200, meta.header.merge("X-Sendfile" => meta.path.to_s), ""]
        elsif etag != meta.etag
          if !env.nil? && meta.size > 30_000 && Blobsterix.allow_chunked_stream
            chunkresponse
          else
            [200, meta.header, (with_data ? File.open(meta.path, "rb") : "")]
          end
        else
          [304, meta.header, ""]
        end
      end

      private

      def chunkresponse
        f = File.open(meta.path)
        EM.next_tick do
          send_chunk(f)
        end
        [200, meta.header.merge(Goliath::Response::CHUNKED_STREAM_HEADERS), (with_data ? Goliath::Response::STREAMING : "")]
      end

      def send_chunk(file)
        dat = file.read(10_000)
        again = if !dat.nil?
                  env.chunked_stream_send(dat)
                  true
        else
          file.close
          env.chunked_stream_close
          false
        end
        EM.next_tick do
          send_chunk(file)
        end if again
      end
    end
  end
end
