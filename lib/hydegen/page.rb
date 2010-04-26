module Hydegen
  class Page 
    attr :filename, :renderer, :meta,
         :page, :layout, :project

    attr_accessor :filename
    attr_accessor :meta
    attr_accessor :data
    attr_accessor :name

    attr_reader :project

    # Constructor.
    #
    # The `page` argument is a page name
    #
    def initialize( page, project )
      @project = project
      @name ||= page
      @meta ||= {}

      renderer = nil

      info = get_page_info(self, @project)
      @filename = info[:filename]
      @renderer = info[:renderer]
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

    protected
    def get_page_info(page, project)
      renderer = nil
      filename = "#{project.root}/#{page.name}"

      if File.exists? filename
        renderer = Hydegen::Renderer::Passthru

      else
        # Look for the file
        matches = Dir["#{project.root}/#{page.name}.*"]
        raise NotFound.new("Can't find `#{page.name}` or `#{page.name}.*`") \
          if matches.empty?

        # Check for a matching renderer
        exts = []
        matches.each do |match|
          begin
            ext      = File.extname(match)[1..-1].capitalize.to_sym
            r_class  = Hydegen::Renderers.const_get(ext)
            exts     << ext
            renderer ||= r_class
            filename = match
          rescue NoMethodError; end
        end

        raise NotFound.new("No matching renderers found: " + exts.inspect) \
          if renderer.nil?
      end

      { :renderer => renderer.new(page, filename),
        :filename => filename
      }
    end
  end
end
