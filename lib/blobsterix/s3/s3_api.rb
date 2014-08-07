module Blobsterix
  class S3Api < AppRouterBase
    include S3UrlHelper

    get "/", :list_buckets

    get "/*bucket_or_file.:format", :get_file
    get "/*bucket_or_file", :get_file

    head "/*bucket_or_file.:format", :get_file_head
    head "/*bucket_or_file", :get_file_head

    put "/", :create_bucket

    put "/*file.:format", :upload_data
    put "/*file", :upload_data

    delete "/", :delete_bucket
    delete "/*file.:format", :delete_file
    delete "/*file", :delete_file

    get "*any", :next_api
    put "*any", :next_api
    delete "*any", :next_api
    head "*any", :next_api
    post "*any", :next_api

    private
      def list_buckets
        Blobsterix.event("s3_api.list_bucket",:bucket => bucket)
        Http.OK storage.list(bucket).to_xml, "xml"
      end

      def get_file(send_with_data=true)
        return Http.NotFound if favicon

        if bucket?
          if meta = storage.get(bucket, file)
            send_with_data ? meta.response(true, env["HTTP_IF_NONE_MATCH"], env) : meta.response(false)
          else
            Http.NotFound
          end
        else
          Blobsterix.event("s3_api.list_bucket",:bucket => bucket)
          start_path = env["params"]["marker"] if env["params"]
          Http.OK storage.list(bucket, :start_path => start_path).to_xml, "xml"
        end
      end

      def get_file_head
                           #TODO: add event?
        get_file(false)
      end

      def create_bucket
              Blobsterix.event("s3_api.upload",:bucket => bucket)
        Http.OK storage.create(bucket), "xml"
      end

      def upload_data
        source = cached_upload
        accept = AcceptType.new("*/*")#source.accept_type()

        trafo_current = trafo(trafo_string)
        file_current = file
        bucket_current = bucket
        Blobsterix.event("s3_api.upload", :bucket => bucket_current, 
                                              :file => file_current, :accept_type => accept.type, :trafo => trafo_current)
        blob_access=BlobAccess.new(:source => source, :bucket => bucket_current, :id => file_current, :accept_type => accept, :trafo => trafo_current)
        data = transformation.run(blob_access)
        cached_upload_clear
        storage.put(bucket_current, file_current, data.open, :close_after_write => true).response(false)
      end

      def delete_bucket
        Blobsterix.event("s3_api.delete_bucket", :bucket => bucket)

        if bucket?
          Http.OK_no_data storage.delete(bucket), "xml"
        else
          Http.NotFound "no such bucket"
        end
      end

      def delete_file
         Blobsterix.event("s3_api.delete_file", :bucket => bucket,:file => file)
        if bucket?
          Http.OK_no_data storage.delete_key(bucket, file), "xml"
        else
          Http.NotFound "no such bucket"
        end
      end
  end
end
