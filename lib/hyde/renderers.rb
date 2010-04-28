module Hyde
  module Renderers
    class Haml < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require 'haml'
        @engine = ::Haml::Engine.new(@markup, {})
        @engine.render scope, data, &block
      end
    end

    class Erb < Renderer::Parseable
      def evaluate(scope, data={}, &block)
        require 'erb'
        @engine = ERB.new @markup
        @engine.src
      end
    end
  end
end
