module Hyde
  class Page 
    include Hyde::Utils

    attr :filename
    attr :renderer
    attr :meta
    attr :page
    attr :layout
    attr :project

    # The filename of the source file.
    # @example
    #   puts page.name
    #   puts page.filename
    #
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
    #
    def self.[](path, project, def_page_class = Page)
      PageFactory.create path, project, def_page_class
    end

    # Returns the rendered output.
    def render(data = {}, &block)
      output = @renderer.render(data, &block)
      # BUG: @layout should build on top of that data
      output = @layout.render(@meta.merge data) { output }  unless @layout.nil?
      output
    end

    def method_missing(meth, *args, &blk)
      meta[meth.to_s] || meta[meth.to_sym] || super
    end

    def get_binding
      binding
    end

    # Sets the meta data as read from the file.
    #
    # Params:
    #   meta   - The metadata Hash.
    #
    # Called by Renderer::Base.
    #
    def set_meta(meta)
      # TODO: OStruct and stuff
      # Merge
      @meta ||= Hash.new
      @meta.merge! meta

      # Set the Layout
      @layout = @project[@meta['layout'], Layout]  if @meta['layout']
    end

    protected

    # Constructor.
    # The `page` argument is a page name
    # Don't use me: use {Project#[]}
    #
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
  end
end
