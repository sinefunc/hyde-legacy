module Hyde
  module Renderer
    class Base
      @page = nil
      @meta = {}

      attr_reader :meta
      attr_reader :page

      def initialize( page )
        @page = page
      end

      def render
        ""
      end
    end

    class Parsable < Base
      @data = ""
      @parts = []

      def initialize( page )
        super page

        @parts = get_file_parts @page.filename, :max_parts => 2
        if @parts.length == 1
          # If it doesn't come with a header, assume the whole file is the data
          @data = @parts[0]
        else
          @meta = @parts[0]
          @data = @parts[1]
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
      def render
        data = ""
        File.open(@page.filename, "r").each_line { |line| data << line }
        data
      end
    end

    class HAML < Parsable
      def render
        @engine = ::Haml::Engine.new(@data, {})
        @engine.render
      end
    end
  end
end
