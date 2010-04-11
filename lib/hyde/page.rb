module Hyde
  class Page 
    @parts = nil
    @filename = []
    @renderer = nil
    @meta = {}
    @basepath = nil
    @page
    @layout = nil

    attr_accessor :filename
    attr_accessor :meta
    attr_accessor :data
    attr_accessor :page

    # Constructor.
    #
    # The `p_page` is a page name
    def initialize( p_page )
      @page ||= p_page
      @basepath ||= PROJECT.root

      renderer = nil
      PROJECT.renderers.each do |extension, r|
        @filename = "#{@basepath}/#{@page}#{extension}"
        if File.exists? @filename
          @renderer = r.new self
          break
        end
      end

      if @renderer.nil?
        raise Hyde::NotFound
      end
    end

    # Returns the rendered output.
    def render( data = {} )
       output = @renderer.render data
       unless @layout.nil?
         hash = { "content" => output }
         output = @layout.render hash
       end
       output
    end

    # Sets the meta data as read from the file.
    #
    # Params:
    #   meta   - The metadata Hash.
    #
    # Called by Renderer::Base.
    #
    def set_meta( meta )
      # Merge
      @meta ||= Hash.new
      @meta.merge! meta

      # Set the Layout
      @layout = Layout.new @meta['layout'] if @meta['layout']
    end
  end

  class Layout < Page
    def initialize( p_template )
      @basepath = PROJECT.root + "/_layouts"
      super p_template
    end
  end
end
