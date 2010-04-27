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

    def force_file_open(basepath, path, mode="w")
      mkdir_p basepath, File.dirname(path)
      File.new(File.join(basepath, path), mode)
    end

    def mkdir_p(basepath, path)
      base = basepath
      path.split('/').reject(&:empty?).unshift('').each do |segment|
        base = File.join(base, segment)
        begin; Dir.mkdir(base)
        rescue Errno::EEXIST; end
      end
    end
  end
end
