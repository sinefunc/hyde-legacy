module Hyde
  # HAXXX... to be deprecated
  class Scope
    def data=(data)
      @data = OpenStruct.new(data)
    end

    def method_missing(meth, *args, &blk)
      @data.send meth
    end
  end
end
