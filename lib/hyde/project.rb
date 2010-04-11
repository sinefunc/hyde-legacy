module Hyde
  class Project
    @renderers = {}
    @root = ''

    attr_accessor :renderers
    attr_reader :root

    def initialize
      @renderers = {}
      @renderers[''] = Renderer::Passthru
      @renderers['.haml'] = Renderer::HAML

      @root = Dir.pwd
    end

    def render( pathname )
      pathname = "index.html" if pathname == ""
      page = Page.new pathname
      page.render
    end
  end

  PROJECT = Project.new
end
