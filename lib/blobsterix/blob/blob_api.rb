module Blobsterix
	class BlobApi < AppRouterBase
		include BlobUrlHelper

		get "/blob/v1", :function => :not_allowed
		get "/blob", :function => :not_allowed
		put "/blob/v1", :function => :not_allowed
		put "/blob", :function => :not_allowed

		get "/blob/v1/(:trafo.)*bucket_or_file.:format", :function => :get_file
		get "/blob/v1/(:trafo.)*bucket_or_file", :function => :get_file

		head "/blob/v1/(:trafo.)*bucket_or_file.:format", :function => :get_file_head
		head "/blob/v1/(:trafo.)*bucket_or_file", :function => :get_file_head

		get "*any", :function => :next_api
		put "*any", :function => :next_api
		delete "*any", :function => :next_api

		private
			def not_allowed
				Http.NotAllowed "listing blob server not allowed"
			end

			def get_file
				accept = AcceptType.get(env, format)[0]

				# check trafo encryption
				trafo_string = Blobsterix.decrypt_trafo(env[nil][:trafo] || "", logger)
				return Blobsterix::Storage::BlobMetaData.new.response if !trafo_string

				data = transformation.run(:bucket => bucket, :id => file, :type => accept, :trafo => trafo_string)
				data.response(true, env["HTTP_IF_NONE_MATCH"], env, env["HTTP_X_FILE"] === "yes")
			end

			def get_file_head
				logger.debug "Blob head"
				accept = AcceptType.get(env, format)[0]

				# check trafo encryption
				trafo_string = Blobsterix.decrypt_trafo(env[nil][:trafo] || "", logger)
				return Blobsterix::Storage::BlobMetaData.new.response if !trafo_string

				data = transformation.run(:bucket => bucket, :id => file, :type => accept, :trafo => trafo_string)
				data.response(false)
			end
	end
end