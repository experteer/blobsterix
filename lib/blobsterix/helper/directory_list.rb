module Blobsterix
  class DirectoryWalker
    attr_accessor :path, :child_walker, :child_index

    def initialize(base_path, opts = {})
      @current_id = 0
      @child_walker = nil
      @path = Pathname.new base_path
      @child_index = opts[:child_index]
      init_path(opts[:start_path]) if opts[:start_path]
    end

    def init_path(start_path)
      @start = Pathname.new(start_path)
      myentry = path_root(@start)

      entries.each_with_index do |entry,index|
        @current_id=index+1 if myentry.to_s == entry.to_s
      end

      set_childwalker(path.join(myentry), current_id-1, @start.relative_path_from(myentry)) if path.join(myentry).directory?
    end

    def next
      out = nil
      begin
        return current if @child_walker && @child_walker.next
        return nil unless increment_id
        out = current
      end while out == nil
      out
    end

    def entries
      @entries ||= Dir.entries(path).sort
    end

    def current_entry
      entries[@current_id-1]
    end

    def current_id
      return @current_id if @current_id > 0
      increment_id
    end

    def increment_id
      begin
        return nil if @current_id+1 > entries.size
        @current_id+=1
      end while (current_entry == "." || current_entry == "..")
      @current_id
    end

    def current_path
      current_(
        lambda{|walker|walker.current_path},
        lambda{|walker|walker.current_path},
        lambda{|new_path|path}
      )
    end

    def current_file
      current_(
        lambda{|walker|walker.current_file},
        lambda{|walker|walker.current_file},
        lambda{|new_path|entries[current_id-1]}
      )
    end

    def current
      current_(
        lambda{|walker|walker.current},
        lambda{|walker|walker.next},
        lambda{|new_path|new_path}
      )
    end

    private
      def set_childwalker(path_, index_=nil, start_path_=nil)
        options = {}
        options[:child_index] = index_      if index_
        options[:start_path]  = start_path_ if start_path_
        @child_walker = DirectoryWalker.new(path_, options)
      end

      def path_root(path_)
        myentry = nil
        path_.descend do |entry|
          myentry = entry
          break
        end
        myentry
      end

      def current_(on_valid, on_new, on_file)
        return nil unless current_id
        return on_valid.call(@child_walker) if valid_childwalker?

        new_path = path.join(entries[current_id-1])
        if new_path.directory?
          @child_walker = DirectoryWalker.new(new_path, :child_index => current_id-1)
          on_new.call(@child_walker)
        else
          on_file.call(new_path)
        end
      end

      def valid_childwalker?
        @child_walker && @child_walker.child_index == current_id-1
      end
  end
  class DirectoryList
    def self.each_limit(path, opts={})
      used = 0
      limit = opts[:limit]||0
      start_path = opts[:start_path]||nil
      a = DirectoryWalker.new(path, :start_path => start_path)
      while (!limit || used < limit) && a.next
        used +=1 if yield a.current_path, a.current_file
      end
      a
    end
    def self.each(path)
      a = DirectoryWalker.new(path)
      while a.next
        yield a.current_path, a.current_file
      end
    end
  end
end