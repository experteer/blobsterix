require 'fileutils'
require 'benchmark'

module Blobsterix
  module Storage
    class FileSystem < Storage
      include Blobsterix::Logable

      def initialize(path)
        logger.info "Create FileSystem at #{path}"
        @contents = path
        unless Dir.exist?(@contents)
          FileUtils.mkdir_p(@contents)
          FileUtils.touch File.join(@contents,".keep")
        end
      end

      def bucket_exist(bucket="root")
        Dir.entries(contents).include?(bucket) and File.directory?(File.join(contents,bucket))
      end

      def list(bucket="root", opts={})
        if bucket =~ /root/
          list_buckets
        else
          if bucket_exist(bucket)
            b = Bucket.new(bucket, time_string_of(bucket))
            b.marker = opts[:start_path] if opts[:start_path]
            Blobsterix.wait_for(Proc.new {
              collect_bucket_entries(bucket, b, opts)
            })
            b
          else
            Nokogiri::XML::Builder.new do |xml|
              xml.Error "no such bucket"
            end
          end
        end
      end

      def get(bucket, key)
        if (not File.directory?(contents(bucket, key))) # and bucket_files(bucket).include?(key)
          Blobsterix.storage_read(BlobAccess.new(:bucket => bucket, :id => key))
          metaData(bucket, key)
        else
          Blobsterix.storage_read_fail(BlobAccess.new(:bucket => bucket, :id => key))
          Blobsterix::Storage::BlobMetaData.new
        end
      end

      def put(bucket, key, value, opts={})
        Blobsterix.storage_write(BlobAccess.new(:bucket => bucket, :id => key))

        meta = Blobsterix.wait_for(Proc.new {metaData(bucket, key).write() {|f| FileUtils.copy_stream(value, f) }})

        value.close if opts[:close_after_write]

        Blobsterix.wait_for(Proc.new {Blobsterix.cache.invalidate(Blobsterix::BlobAccess.new(:bucket => bucket, :id => key))})

        meta
      end

      def create(bucket)
        logger.info "Storage: create bucket #{contents(bucket)}"
        FileUtils.mkdir_p(contents(bucket)) if not File.exist?(contents(bucket))

        Nokogiri::XML::Builder.new do |xml|
        end.to_s
      end

      def delete(bucket)
        logger.info "Storage: delete bucket #{contents(bucket)}"
        FileUtils.rm_rf(contents(bucket)) if bucket_exist(bucket) && bucket_empty?(bucket)
        #Dir.rmdir(contents(bucket)) if bucket_exist(bucket) && bucket_files(bucket).empty?
      end

      def delete_key(bucket, key)
        Blobsterix.storage_delete(BlobAccess.new(:bucket => bucket, :id => key))
        Blobsterix.wait_for(Proc.new {Blobsterix.cache.invalidate(Blobsterix::BlobAccess.new(:bucket => bucket, :id => key))})

        metaData(bucket, key).delete # if bucket_files(bucket).include? key
      end

      private
        def list_buckets
          BucketList.new do |l|
            Dir.entries("#{contents}").each{|dir|
              l.buckets << Bucket.new(dir, time_string_of(dir)) if File.directory? File.join("#{contents}",dir) and !(dir =='.' || dir == '..') 
            }
          end
        end
        def collect_bucket_entries(bucket, b, opts)
          start_path = map_filename(opts[:start_path].to_s.gsub("/", "\\")) if opts[:start_path]
          current_obj = Blobsterix::DirectoryList.each_limit(contents(bucket), :limit => 20, :start_path => start_path) do |path, file|
            if file.to_s.end_with?(".meta")
              false
            else
              b.contents << BucketEntry.create(file, metaData(bucket, file.to_s))
              true
            end
          end
          next_marker = current_obj.current_file.to_s.gsub("\\", "/")
          if current_obj.next
            b.next_marker=next_marker
            b.truncated=true
          end
        end
        def contents(bucket=nil, key=nil)
          if bucket
            key ? File.join(@contents, bucket, map_filename(key.gsub("/", "\\"))) : File.join(@contents, bucket)
          else
            @contents
          end
        end

        def map_filename(filename)
          Murmur.map_filename(filename, filename)
        end

        def bucket_empty?(bucket)
          empty = true
          Blobsterix::DirectoryList.each(contents(bucket)) do
            empty = false
            break
          end
          empty
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
