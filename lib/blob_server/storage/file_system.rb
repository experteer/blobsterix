require 'fileutils'

module BlobServer
	module Storage
		class FileSystem < Storage

			def initialize(path="../contents")
				@contents = path
				@metaData = {}
			end

			def contents
				@contents
			end

			def metaData(bucket, key)
				@metaData[[bucket, key].join("_")] ||= BlobServer::Storage::FileSystemMetaData.new(File.join(contents, bucket), key)
			end

			def time_string_of(*file_name)
				File.ctime("#{contents}/#{file_name.flatten.join("/")}").strftime("%Y-%m-%dT%H:%M:%S.000Z")
			end

			def bucket_exist(bucket="root")
				Dir.entries(contents).include?(bucket) and File.directory?(File.join(contents,bucket))
			end

			def bucket_files(bucket)
				if (bucket_exist(bucket))
					Dir.glob("#{contents}/#{bucket}/**/*").map{|e|e.gsub("#{contents}/#{bucket}/","")}
				else
					[]
				end
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
								entry.last_modified =  metaData(bucket, file).last_modified
								entry.etag =  metaData(bucket, file).etag
								entry.size =  metaData(bucket, file).size
								entry.mimetype = metaData(bucket, file).mimetype
							end if not File.directory? File.join("#{contents}", bucket, file) and !(file =='.' || file == '..')
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
				puts "GET: #{contents}/#{bucket}/#{key}"
				if (not File.directory?(File.join(contents, bucket, key))) and bucket_files(bucket).include?(key)
					metaData(bucket, key)
				else
					@metaData.delete(key)
					BlobServer::Storage::BlobMetaData.new
				end
			end

			def put(bucket, key, value)
				puts "Write data to #{File.join("#{contents}/", bucket, key)}"
				FileUtils.mkdir_p(File.dirname(File.join("#{contents}/", bucket, key)))
				File.open(File.join("#{contents}/", bucket, key), 'wb') {|f| f.write(value.read) }
				@metaData.delete(key)
				metaData(bucket, key)
			end

			def post(bucket, value)
			end

			def create(bucket)
				FileUtils.mkdir_p(File.join("#{contents}", bucket)) if not File.exist?(File.join("#{contents}", bucket))
				Nokogiri::XML::Builder.new do |xml|
				end
			end

			def delete(bucket)
				puts "Delete bucket #{File.join("#{contents}/", bucket)}"
				Dir.rmdir(File.join("#{contents}", bucket)) if bucket_exist(bucket)
				#Nokogiri::XML::Builder.new do |xml|
				#end
			end

			def delete_key(bucket, key)
				puts "Delete File #{File.join("#{contents}/", bucket, key)}"
				if bucket_files(bucket).include? key
					@metaData.delete(key)
					File.delete(File.join("#{contents}", bucket, key))
				end
				#Nokogiri::XML::Builder.new do |xml|
				#end
			end
		end
	end
end