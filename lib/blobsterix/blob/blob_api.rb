module Blobsterix
  class BlobApi < AppRouterBase
    include BlobUrlHelper
    include UrlHelper

    get "/blob/v1", :not_allowed
    get "/blob", :not_allowed
    put "/blob/v1", :not_allowed
    put "/blob", :not_allowed

    get "/blob/v1/(:trafo.)*bucket_or_file.:format", :get_file
    get "/blob/v1/(:trafo.)*bucket_or_file", :get_file

    head "/blob/v1/(:trafo.)*bucket_or_file.:format", :get_file_head
    head "/blob/v1/(:trafo.)*bucket_or_file", :get_file_head

    get "*any", :next_api
    put "*any", :next_api
    delete "*any", :next_api
    head "*any", :next_api
    post "*any", :next_api

    private

    def not_allowed
      Http.NotAllowed "listing blob server not allowed"
    end

    def get_file(send_with_data = true)
      accept = AcceptType.get(env, format)[0]

      # check trafo encryption
      trafo_string = Blobsterix.decrypt_trafo(BlobAccess.new(:bucket => bucket, :id => file), transformation_string, logger)
      unless trafo_string
        Blobsterix.encryption_error(BlobAccess.new(:bucket => bucket, :id => file))
        return Http.NotAuthorized
      end

      blob_access = BlobAccess.new(:bucket => bucket, :id => file, :accept_type => accept, :trafo => trafo(trafo_string))
      Blobsterix.storage_event_listener.call("blob_api.get", :trafo_string => trafo_string, :blob_access => blob_access)

      begin
        data = transformation.run(blob_access)
        send_with_data ? data.response(true, env["HTTP_IF_NONE_MATCH"], env) : data.response(false)
      rescue Errno::ENOENT => e
        logger.error "Cache deleted: #{blob_access}"
        Blobsterix.cache_fatal_error(blob_access)
        Http.ServerError
      end
    end

    def get_file_head
      get_file(false)
    end
  end
end
