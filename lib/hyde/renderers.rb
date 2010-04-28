module Hyde
  module Renderers
    class Haml < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require 'haml'
        @engine = ::Haml::Engine.new(@markup, {})
        if page.is_a? Layout
        end
        @engine.render scope, data, &block
      end
    end

    class Erb < Renderer::Parsable
      def evaluate(scope, data={}, &block)
        require 'erb'
        @engine = ::ERB.new @markup
        # So that we can yield!
        eval("self", scope).eval_block @engine.src, &block
      end
    end
  end
end
