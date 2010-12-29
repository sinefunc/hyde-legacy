module Hyde
  class Page 
    include Hyde::Utils

    attr :renderer

    # The filename of the source file.
    #
    # @example
    #   puts page.name
    #   puts page.filename
    #
    #   # about/index.html
    #   # about/index.html.haml
    #
    attr_accessor :filename

    # Metadata hash
    attr_accessor :meta

    # Path
    # @see {#filename} for an example
    attr_accessor :name

    # A reference to the parent {Project} instance
    attr_reader :project

    attr_accessor :referrer

    DEFAULT_LAYOUT = 'default'

    # Factory
    #
    def self.[](path, project, def_page_class = Page)
      PageFactory.create path, project, def_page_class
    end

    # Returns the rendered output.
    def render(data = {}, &block)
      output = content(data, &block)
      output = layout.render(get_data(data)) { output }  unless layout.nil?
      output
    end

    # Returns the HTML content.
    def content(data = {}, &block)
      @renderer.render(get_data(data), &block)
    end

    def layout=(val)
      @layout = val
    end

    def layout
      begin
        @layout ||= project[DEFAULT_LAYOUT, :Layout]  if !@renderer.nil? and @renderer.layoutable? and meta.layout != false
        @layout
      rescue NotFound
        nil
      end
    end

    def title
      @title ||= if meta.title
        meta.title
      elsif is_index?
        File.basename(File.dirname(filename))
      else
        File.basename(filename, '.*')
      end
    end

    # Returns the URL path for the page.
    def path
      @url ||= begin
        if renderer.is_a?(Renderer::Passthru)
          '/' + @name
        else
          url = [ File.dirname(@name), File.basename(@filename) ]
          url[1] = File.basename(url[1], '.*')
          url[1] = (url[1] + @renderer.default_ext)  unless url[1].include?('.')
          '/' + url.join('/')
        end
      end
    end

    def output_path
      File.join(project.config.output_path, path)
    end

    def get_binding #(&blk)
      binding
    end

    def to_s
      name
    end

    def to_sym
      (filename).to_sym
    end

    def <=>(other)
      result = self.position <=> other.position
      result ||= self.position.to_s <=> other.position.to_s
      result
    end

    def position
      meta.position || title
    end

    def parent
      folder = File.dirname(@name)
      folder = File.join(folder, '..')  if is_index?
      folder = File.expand_path(folder)

      files = Dir[File.join(folder, 'index.*')]
      return nil  if files.empty?

      page = PageFactory.create(files.first, @project)
      return nil  if page === self

      page
    end

    def children
      return []  unless is_index?
      folder = File.dirname(@name)

      get_pages_from folder
    end

    def siblings
      folder = File.dirname(@name)
      folder = File.join(folder, '..')  if is_index?

      get_pages_from folder
    end

    def get_pages_from(folder)
      # Sanity check: don't go beyond the root
      return []  unless File.expand_path(folder).include?(File.expand_path(@project.root(:site)))

      files  = Dir[@project.root(:site, folder, '*')]
      files.inject([]) do |a, name|
        if File.directory?(name)
          name = Dir[File.join(name, 'index.*')].first
          a << PageFactory.create(name, @project)  unless name.nil?

        else
          page = PageFactory.create name, @project
          a << page  unless page.is_index?

        end
        a
      end.sort
    end

    # Returns an array of the page's ancestors, starting from the root page.
    def breadcrumbs
      @crumbs ||= parent.nil? ? [] : (parent.breadcrumbs + [parent])
    end

    def ===(other)
      return false  if other.nil?
      super || (File.expand_path(self.filename) === File.expand_path(other.filename))
    end

    def next
      siblings.each_cons(2) { |(i, other)| return other  if i === self }
    end

    def previous
      siblings.each_cons(2) { |(other, i)| return other  if i === self }
    end

    def is_index?
      !@name.match(/(^|\/)index/).nil?
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

  private

    # Data for rendering
    def get_data(data)
      data = @meta | data
      data[:page] ||= self
      data
    end
  end
end
