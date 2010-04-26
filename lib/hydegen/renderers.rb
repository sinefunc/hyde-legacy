require 'haml'

module Hydegen
  module Renderers
    class Haml < Renderer::Parsable
      def render( data = {} )
        @engine = ::Haml::Engine.new(@markup, {})

        if data.is_a? Hash
          @engine.render OpenStruct.new data
        else
          @engine.render data
        end
      end
    end
  end
end
