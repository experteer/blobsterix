module Blobsterix
	class S3Api < AppRouterBase
		include S3UrlHelper

		get "/", :function => :list_buckets

		get "/*bucket_or_file.:format", :function => :get_file
		get "/*bucket_or_file", :function => :get_file

		head "/*bucket_or_file.:format", :function => :get_file_head
		head "/*bucket_or_file", :function => :get_file_head

		put "/", :function => :create_bucket

		put "/*file.:format", :function => :upload_data
		put "/*file", :function => :upload_data

		delete "/", :function => :delete_bucket
		delete "/*file.:format", :function => :delete_file
		delete "/*file", :function => :delete_file

		private
			def list_buckets
				Http.OK storage.list(bucket).to_xml, "xml"
			end

			def get_file
				return Http.NotFound if favicon

				if bucket?
					if meta = storage.get(bucket, file)
						meta.response
					else
						Http.NotFound
					end
				else
					Http.OK storage.list(bucket).to_xml, "xml"
				end
			end

			def get_file_head
				return Http.NotFound if favicon
				logger.debug "S3 head"

				if bucket?
					if meta = storage.get(bucket, file)
						meta.response(false)
					else
						Http.NotFound
					end
				else
					Http.OK storage.list(bucket).to_xml, "xml"
				end
			end

			def create_bucket
				Http.OK storage.create(bucket), "xml"
			end

			def upload_data
				source = cached_upload
				accept = source.accept_type()
				trafo = trafo
				file = file
				bucket = bucket
				logger.info "UploadFile => Bucket: #{bucket} - File: #{file} - Accept: #{accept} - Trafo: #{trafo}"
				data = transformation.run(:source => source, :bucket => bucket, :id => file, :type => accept, :trafo => trafo)
				cached_upload_clear
				storage.put(bucket, file, data).response(false)
			end

			def delete_bucket
				if bucket?
					Http.OK_no_data storage.delete(bucket), "xml"
				else
					Http.NotFound "no such bucket"
				end
			end

			def delete_file
				if bucket?
					Http.OK_no_data storage.delete_key(bucket, file), "xml"
				else
					Http.NotFound "no such bucket"
				end
			end
	end
end
