module Hyde
  module Renderers
    class Haml < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require 'haml'
        @engine = ::Haml::Engine.new(markup, {})
        @engine.render scope, data, &block
      end
    end

    class Erb < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require 'erb'
        @engine = ::ERB.new markup
        # So that we can yield!
        eval("self", scope).eval_block @engine.src, &block
      end
    end

    class Less < Renderer::Base
      def evaluate(scope, data={}, &block)
        require 'less'
        @engine = ::Less::Engine.new(File.open(filename))
        @engine.to_css
      end
    end

    #class Sass < Renderer::Base
    #  def evaluate(scope, data={}, &block)
    #    require 'haml'
    #    @engine = ::Sass::Engine.new(File.open(filename))
    #  end
    #end

    #class Md < Renderer::Parsable
    #end

    #class Textile < Renderer::Parsable
    #end
  end
end
