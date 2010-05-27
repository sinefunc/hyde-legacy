module Hyde
  module Renderers
    class Haml < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require_lib 'haml'
        begin
          @engine = ::Haml::Engine.new(markup, {})
          @engine.render scope, data, &block
        rescue ::Haml::SyntaxError => e
          raise Hyde::RenderError.new(e.message, :line => e.line)
        end
      end
    end

    class Erb < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require_lib 'erb'
        @engine = ::ERB.new markup
        eval @engine.src, scope
      end
    end

    class Less < Renderer::Base
      def evaluate(scope, data={}, &block)
        require_lib 'less'
        begin
          @engine = ::Less::Engine.new(File.open(filename))
          @engine.to_css
        rescue ::Less::SyntaxError => e
          matches = /^on line ([0-9]+): (.*)$/.match(e.message)
          line    = matches[1]
          message = matches[2]
          raise Hyde::RenderError.new(message, :line => line)
        end
      end
    end

    #class Sass < Renderer::Base
    #  def evaluate(scope, data={}, &block)
    #    require 'haml'
    #    @engine = ::Sass::Engine.new(File.open(filename))
    #  end
    #end

    class Md < Renderer::Parsable
      def evaluate(s, d={}, &block)
        require_lib 'maruku'
        Maruku.new(markup).to_html
      end
    end

    class Textile < Renderer::Parsable
      def evaluate(s, d={}, &block)
        require_lib 'redcloth', 'RedCloth'
        RedCloth.new(markup).to_html
      end
    end
  end
end
