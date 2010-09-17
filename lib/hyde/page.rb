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

    attr_accessor :layout

    attr_accessor :referrer

    # Factory
    #
    def self.[](path, project, def_page_class = Page)
      PageFactory.create path, project, def_page_class
    end

    # Returns the rendered output.
    def render(data = {}, &block)
      data = @meta | data
      data[:page] ||= self
      output = @renderer.render(data, &block)
      output = @layout.render(data) { output }  unless @layout.nil?
      output
    end

    def title
      meta.title || File.basename(filename, '.*')
    end

    # Returns the URL path for the page.
    def path
      return @url  unless @url.nil?

      url = File.split(@name)
      url[1] = File.basename(url[1], '.*')
      url[1] = (url[1] + @renderer.default_ext)  unless url[1].include?('.')
      @url = '/' + url.join('/')
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
      (self.meta.position || 9999) <=> (other.meta.position || 9999)
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

    def siblings
      folder = File.dirname(@name)
      folder = File.join(folder, '..')  if is_index?

      # Sanity check: don't go beyond the root
      return nil  unless File.expand_path(folder).include?(File.expand_path(@project.root(:site)))

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
  end
end
