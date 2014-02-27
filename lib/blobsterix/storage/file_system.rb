require 'fileutils'

module Blobsterix
  module Storage
    class FileSystem < Storage
      include Blobsterix::Logable

      def initialize(path)
        logger.info "Create FileSystem at #{path}"
        @contents = path
        FileUtils.mkdir_p(@contents) if !Dir.exist?(@contents)
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
        if (not File.directory?(contents(bucket, key))) and bucket_files(bucket).include?(key)
          Blobsterix.storage_read(BlobAccess.new(:bucket => bucket, :id => key))
          metaData(bucket, key)
        else
          Blobsterix.storage_read_fail(BlobAccess.new(:bucket => bucket, :id => key))
          Blobsterix::Storage::BlobMetaData.new
        end
      end

      def put(bucket, key, value)
        Blobsterix.storage_write(BlobAccess.new(:bucket => bucket, :id => key))

        metaData(bucket, key).write() {|f| f.write(value.read) }
      end

      def create(bucket)
        logger.info "Storage: create bucket #{contents(bucket)}"
        FileUtils.mkdir_p(contents(bucket)) if not File.exist?(contents(bucket))

        Nokogiri::XML::Builder.new do |xml|
        end
      end

      def delete(bucket)
        logger.info "Storage: delete bucket #{contents(bucket)}"

        Dir.rmdir(contents(bucket)) if bucket_exist(bucket)
      end

      def delete_key(bucket, key)
        Blobsterix.storage_delete(BlobAccess.new(:bucket => bucket, :id => key))

        metaData(bucket, key).delete if bucket_files(bucket).include? key
      end

      private
        def contents(bucket=nil, key=nil)
          if bucket
            File.join(@contents, bucket)
            File.join(@contents, bucket, map_filename(key.gsub("/", "\\"))) if key
          else
            @contents
          end
        end

        def map_filename(filename)
          hash = Murmur.Hash64B(filename)
          bits =  hash.to_s(2)
          parts = []
          6.times { |index|
            len = 11
            len = bits.length if len >= bits.length
            value = bits.slice!(0, len).to_i(2).to_s(16).rjust(3,"0")
            parts.push(value)
          }
          parts.push(filename)
          parts.join("/")
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