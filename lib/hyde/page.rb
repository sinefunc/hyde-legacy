module Hyde
  class Page 
    @parts = nil
    @filename = []
    @renderer = nil
    @page

    attr_accessor :filename
    attr_accessor :meta
    attr_accessor :data
    attr_accessor :page

    def initialize( p_page )
      @page = p_page

      renderer = nil
      PROJECT.renderers.each do |extension, r|
        @filename = PROJECT.root + "/#{@page}#{extension}"
        if File.exists? @filename
          @renderer = r.new self
          break
        end
      end

      if @renderer.nil?
        raise Hyde::NotFound
      end
    end

    def render
      @renderer.render
    end
  end
end
