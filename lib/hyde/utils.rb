module Hyde
  module Utils
    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end

    def matches_files?(needle, haystack)
      haystack.inject(false) do |a, match|
        a ||= same_file?(needle, match)
      end
    end

    def force_file_open(filepath)
      require 'fileutils'
      FileUtils.mkdir_p File.dirname(filepath)
      File.new filepath, 'w'
    end
  end
end
