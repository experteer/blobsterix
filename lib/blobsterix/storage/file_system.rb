require 'fileutils'

module Blobsterix
	module Storage
		class FileSystem < Storage
			include Blobsterix::Logable

			def initialize(path="../contents")
				@contents = path
				FileUtils.mkdir_p(@contents)
			end

			def bucket_exist(bucket="root")
				Dir.entries(contents).include?(bucket) and File.directory?(File.join(contents,bucket))
			end

			def list(bucket="root")
				if bucket =~ /root/
					BucketList.new do |l|

						Dir.entries("#{contents}").each{|dir|
							l.buckets << Bucket.new(dir, time_string_of(dir)) if File.directory? File.join("#{contents}",dir) and !(dir =='.' || dir == '..') 
						}
					end
				else
					if bucket_exist(bucket)
						b = Bucket.new(bucket, time_string_of(bucket))
						bucket_files(bucket).each do |file|
							b.contents << BucketEntry.new(file) do |entry|
								meta = metaData(bucket, file)
								entry.last_modified =  meta.last_modified
								entry.etag =  meta.etag
								entry.size =  meta.size
								entry.mimetype = meta.mimetype
								entry.fullpath = contents(bucket, file).gsub("#{contents}/", "")
							end
						end
						b
					else
						Nokogiri::XML::Builder.new do |xml|
							xml.Error "no such bucket"
						end
					end
				end
			end

			def get(bucket, key)
				logger.debug "GET: #{contents(bucket, key)}"
				if (not File.directory?(contents(bucket, key))) and bucket_files(bucket).include?(key)
					metaData(bucket, key)
				else
					Blobsterix::Storage::BlobMetaData.new
				end
			end

			def put(bucket, key, value)
				logger.info "Write data to #{contents(bucket, key)}"

				metaData(bucket, key).write() {|f| f.write(value.read) }
			end

			def create(bucket)
				FileUtils.mkdir_p(contents(bucket)) if not File.exist?(contents(bucket))

				Nokogiri::XML::Builder.new do |xml|
				end
			end

			def delete(bucket)
				logger.info "Delete bucket #{contents(bucket)}"

				Dir.rmdir(contents(bucket)) if bucket_exist(bucket)
			end

			def delete_key(bucket, key)
				logger.info "Delete File #{contents(bucket, key)}"

				metaData(bucket, key).delete if bucket_files(bucket).include? key
			end

			private
				def contents(bucket=nil, key=nil)
					if bucket
						File.join(@contents, bucket)
						File.join(@contents, bucket, Murmur.map_filename(key.gsub("/", "\\"))) if key
					else
						@contents
					end
				end

				def bucket_files(bucket)
					if (bucket_exist(bucket))
						Dir.glob("#{contents}/#{bucket}/**/*").select{|e| !File.directory?(e) and not e.end_with?(".meta")}.map{ |e|
							e.gsub("#{contents}/#{bucket}/","").gsub(/\w+\/\w+\/\w+\/\w+\/\w+\/\w+\//, "").gsub("\\", "/")
						}
					else
						[]
					end
				end

				def metaData(bucket, key)
					Blobsterix::Storage::FileSystemMetaData.new(contents(bucket, key))
				end

				def time_string_of(*file_name)
					File.ctime("#{contents}/#{file_name.flatten.join("/")}").strftime("%Y-%m-%dT%H:%M:%S.000Z")
				end
		end
	end
end