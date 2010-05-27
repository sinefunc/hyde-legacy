module Hyde
  module Helpers
    module Default
      def partial(partial_path, args = {})
        locals = args[:locals] || {}
        p = project[partial_path.to_s, :Partial]
        p.render locals
      end
    end

    include Default
  end
end
