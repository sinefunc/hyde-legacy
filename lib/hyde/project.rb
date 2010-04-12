module Hyde
  class Project
    @config_file = nil

    @root = nil
    @layouts_root = nil
    @extensions_root = nil

    @renderers = nil
    @config = nil

    attr_reader :root
    attr_reader :layouts_root
    attr_reader :extensions_root

    attr_accessor :renderers
    attr_accessor :config

    def initialize
      @renderers ||= {}
      @renderers[''] = Renderer::Passthru
      @renderers['.haml'] = Renderer::HAML

      @root ||= Dir.pwd
      @layouts_root ||= "#{@root}/_layouts"
      @extensions_root ||= "#{@root}/_extensions"
      @config_file ||= "#{@root}/_config.yml"
      @config = YAML::load @config_file if File.exists? @config_file
    end

    def render( pathname )
      pathname = "index.html" if pathname.empty?
      page = Page.new pathname, self
      page.render
    end
  end
end
