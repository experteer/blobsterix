module Blobsterix
  class SimpleProxy
    def initialize(init_proc)
      @init_proc = init_proc
    end
    def method_missing(meth, *args, &block)
      @proc||=@init_proc.call
      @proc.send(meth, *args, &block)
    end
  end
end