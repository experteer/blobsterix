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
      myentry = nil
      @start.descend do |entry|
        myentry = entry
        break
      end
      begin
        @current_id+=1
        unless entries[@current_id-1]
          @current_id-=1
          break
        end
      end while entries[@current_id-1].to_s != myentry.to_s
      @child_walker = DirectoryWalker.new(path.join(myentry), :child_index => current_id-1, :start_path => @start.relative_path_from(myentry)) if path.join(myentry).directory?
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

    def current_id
      return @current_id if @current_id > 0

      begin
        return nil if @current_id+1 > entries.size
        @current_id+=1
      end while (entries[@current_id-1] == "." || entries[@current_id-1] == "..")
      @current_id
    end

    def increment_id
      begin
        return nil if @current_id+1 > entries.size
        @current_id+=1
      end while (entries[@current_id-1] == "." || entries[@current_id-1] == "..")
      @current_id
    end

    def current_path
      return nil unless current_id
      return @child_walker.current_path if @child_walker && @child_walker.child_index == current_id-1

      new_path = path.join(entries[current_id-1])
      if new_path.directory?
        @child_walker = DirectoryWalker.new(new_path, :child_index => current_id-1)
        @child_walker.current_path
      else
        path
      end
    end

    def current_file
      return nil unless current_id
      return @child_walker.current_file if @child_walker && @child_walker.child_index == current_id-1

      new_path = path.join(entries[current_id-1])
      if new_path.directory?
        @child_walker = DirectoryWalker.new(new_path, :child_index => current_id-1)
        @child_walker.current_file
      else
        entries[current_id-1]
      end
    end

    def current
      return nil unless current_id
      return @child_walker.current if @child_walker && @child_walker.child_index == current_id-1

      new_path = path.join(entries[current_id-1])
      if new_path.directory?
        @child_walker = DirectoryWalker.new(new_path, :child_index => current_id-1)
        @child_walker.next
      else
        new_path
      end
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
      puts "Reached limit" if used >= limit
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