module Hyde
  module Helpers
    def partial(partial_path, args = {})
      locals = args[:locals].nil? ? args : args[:locals] # Legacy

      p = project[partial_path.to_s, :Partial]
      p.render locals
    end
  end
end
