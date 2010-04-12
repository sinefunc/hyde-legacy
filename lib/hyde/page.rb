module Hyde
  class Page 
    @parts = nil
    @filename = nil
    @renderer = nil
    @meta = nil
    @basepath = nil
    @page
    @layout = nil
    @project

    attr_accessor :filename
    attr_accessor :meta
    attr_accessor :data
    attr_accessor :page

    attr_reader :project

    # Constructor.
    #
    # The `p_page` is a page name
    def initialize( p_page, project )
      @project = project
      @page ||= p_page
      @basepath ||= @project.root
      @meta ||= {}

      renderer = nil
      @project.renderers.each do |extension, r|
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
       output = @renderer.render(@meta.merge data)
       unless @layout.nil?
         hash = @meta.merge({ "content" => output })
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
      @layout = Layout.new(@meta['layout'], @project) if @meta['layout']
    end
  end

  class Layout < Page
    def initialize( template, project )
      @basepath = project.layouts_root
      super template, project
    end
  end
end
