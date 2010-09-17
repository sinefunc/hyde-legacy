module Hyde
  class Layout < Page
    def self.get_filename(path, project)
      project.root(:layouts, path)
    end

    def layout
      # Don't try a default layout.
      @layout
    end
  end
end
