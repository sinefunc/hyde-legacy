module Hyde
  class Partial < Layout
    def self.create(path, project, page_class = Partial)
      super path, project, page_class
    end
  end
end
