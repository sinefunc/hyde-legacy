module Hyde
  module Helpers
    module Default
      def render_partial(partial_path, args = {})
        locals = args[:locals] || {}
        p = Partial.create partial_path, project
        p.render locals
      end

      def partial(*a)
        render_partial *a
      end
    end
  end
end
