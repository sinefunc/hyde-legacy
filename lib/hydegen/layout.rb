module Hydegen
  class Layout < Page
    def initialize( template, project )
      super project.layouts_path + '/' + template, project
    end
  end
end
