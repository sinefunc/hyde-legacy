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

    attr_accessor :layout

    # Factory
    #
    def self.[](path, project, def_page_class = Page)
      PageFactory.create path, project, def_page_class
    end

    # Returns the rendered output.
    def render(data = {}, &block)
      output = @renderer.render(data, &block)
      output = @layout.render(@meta.merge data) { output }  unless @layout.nil?
      output
    end

    # Needed by helpers
    def method_missing(meth, *args, &blk)
      super  unless @meta.respond_to? meth
      @meta.send meth, *args, &blk
    end

    def get_binding
      binding
    end

    protected

    # Constructor.
    # The `page` argument is a page name
    # Don't use me: use {Project#[]}
    #
    def initialize(path, project, renderer, filename)
      @project    = project
      @name     ||= path
      @meta     ||= Meta.new self
      @filename   = filename
      @renderer   = renderer.new(self, filename)
    end
    
    def self.get_filename(path, project)
      project.root(:site, path)
    end
  end
end
