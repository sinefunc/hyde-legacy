require "ostruct"

module Hyde
  module Renderer
    class Base
      # Reference to {Page}
      attr_reader :page

      # The filename of the file to be parsed
      attr_reader :filename

      def initialize(page, filename)
        @page = page
        @filename = filename
      end

      def render(data={}, &block)
        scope = Object.new
        evaluate scope, data, &block
      end

      protected
      # Override me
      def evaluate(scope, data={}, &block)
        ""
      end
    end

    # Any filetype that is split with the -- separator
    class Parsable < Base
      @markup = ""

      def initialize(page, filename)
        super page, filename
        
        # Parse out the file's metadata and markup contents
        parts = get_file_parts filename, :max_parts => 2
        if parts.length == 1
          # If it doesn't come with a header, assume the whole file is the data
          @markup = parts[0]
        else
          @markup = parts[1]
          page.set_meta YAML::load("--- " + parts[0])
        end
      end

      protected
      def get_file_parts(filename, *args)
        options = { :max_parts => -1 }
        args.each_pair { |k, v| options[k] = v } if args.is_a? Hash

        data = [""]
        i = 0    # Current part number
        File.open(filename, "r").each_line do |line|
          if ((line.strip == "--") and
              ((i <= options[:max_parts]) or (options[:max_parts] == -1)))
            data[i+=1] = ""
          else
            data[i] << line
          end
        end
        data
      end
    end

    class Passthru < Base
      def render(data = {})
        output = ''
        File.open(@page.filename, "r") { |f| output = f.read }
        output
      end
    end
  end
end
