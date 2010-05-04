module Hyde
  class Layout < Page
    def self.create(path, project, page_class = Layout)
      super path, project, page_class
    end

    def self.get_filename(path, project)
      project.root(:layouts, path)
    end
  end
end
