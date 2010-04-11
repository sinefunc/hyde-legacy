module Hyde
  class Project
    @renderers = {}
    @root = ''
    @config = nil

    attr_accessor :renderers
    attr_accessor :config

    attr_reader :root

    def initialize
      @renderers = {}
      @renderers[''] = Renderer::Passthru
      @renderers['.haml'] = Renderer::HAML

      @root = Dir.pwd

      config_file = "#{@root}/_config.yml"
      @config = YAML::load config_file if File.exists? config_file
    end

    def render( pathname )
      pathname = "index.html" if pathname == ""
      page = Page.new pathname
      page.render
    end
  end

  PROJECT = Project.new
end
