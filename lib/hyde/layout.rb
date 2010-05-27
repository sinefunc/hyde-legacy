module Hyde
  class Layout < Page
    def self.get_filename(path, project)
      project.root(:layouts, path)
    end
  end
end
