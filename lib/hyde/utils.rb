module Hyde
  module Utils
  protected
    def escape_html(str)
      str.
        gsub('&', '&amp;').
        gsub('"', '&quot;').
        gsub('<', '&lt;').
        gsub('>', '&gt;').
        gsub("'", '&39;')
    end

    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end

    def matches_files?(needle, haystack)
      haystack.inject(false) do |a, match|
        a ||= same_file?(needle, match)
      end
    end

    def force_file_open(filepath, &blk)
      require 'fileutils'
      FileUtils.mkdir_p File.dirname(filepath)

      if block_given?
        File.open filepath, 'w', &blk
      else
        File.new filepath, 'w'
      end
    end

    # Returns all helper classes under the Hyde::Helpers module.
    def get_helpers
      Hyde::Helpers.constants.inject([Hyde::Helpers]) do |a, constant|
        mod = Hyde::Helpers.const_get(constant)
        a << mod  if mod.is_a? Module
        a
      end
    end
  end
end
