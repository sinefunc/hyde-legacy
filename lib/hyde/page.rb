module Hyde
  class Page 
    attr :filename, :renderer, :meta,
         :page, :layout, :project

    # The filename of the source file.
    # @example
    #   puts page.name
    #   puts page.filename
    #   # about/index.html
    #   # about/index.html.haml
    attr_accessor :filename

    # Metadata hash
    attr_accessor :meta

    # Path
    # @see {#filename} for an example
    attr_accessor :name

    # A reference to the parent {Project} instance
    attr_reader :project

    # Factory
    def self.create(path, project, page_class = Page)
      info = get_page_info(path, project)
      page = page_class.new(path, project, info[:renderer], info[:filename])
    end

    # Returns the rendered output.
    def render( data = {} )
       output = @renderer.render(@meta.merge(data))
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
    def set_meta(meta)
      # Merge
      @meta ||= Hash.new
      @meta.merge! meta

      # Set the Layout
      @layout = @project.get_layout(@meta['layout'])  if @meta['layout']
    end

    protected
    # Constructor.
    # The `page` argument is a page name
    # Don't use me: use {Project#create}
    def initialize(path, project, renderer, filename)
      @project    = project
      @name     ||= path
      @meta     ||= {}
      @filename   = filename
      @renderer   = renderer.new(self, filename)
    end
    
    def self.get_filename(path, project)
      project.root(:site, path)
    end

    def self.get_page_info(path, project)
      renderer = nil
      filename = get_filename(path, project)

      if File.exists? filename
        renderer = Hyde::Renderer::Passthru

      else
        # Look for the file
        matches = Dir["#{filename}.*"]
        raise NotFound.new("Can't find `#{path}{,.*}` -- #{filename}") \
          if matches.empty?

        # Check for a matching renderer
        exts = []
        matches.each do |match|
          begin
            ext      = File.extname(match)[1..-1].capitalize.to_sym
            r_class  = Hyde::Renderers.const_get(ext)
            exts     << ext
            renderer ||= r_class
            filename = match
          rescue NoMethodError; end
        end

        raise NotFound.new("No matching renderers found: " + exts.inspect) \
          if renderer.nil?
      end

      { :renderer => renderer,
        :filename => filename
      }
    end
  end
end
