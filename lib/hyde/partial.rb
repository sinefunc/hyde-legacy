module Hyde
  class Partial < Layout
    def self.get_filename(path, project)
      project.root(:partials, path)
    end
  end
end
