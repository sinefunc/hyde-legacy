require "ostruct"

module Hyde
  module Renderer
    class Base
      include Hyde::Utils

      # Reference to {Page}
      attr_reader :page

      # The filename of the file to be parsed
      attr_reader :filename

      def initialize(page, filename)
        @page = page
        @filename = filename
      end

      def render(data, &block)
        scope = build_scope(page, data)
        evaluate scope, data, &block
      end

      def markup
        File.open(filename) { |f| @markup = f.read }  unless @markup
        @markup
      end

      protected
      def require_lib(lib, gem=lib)
        begin
          require lib
        rescue LoadError
          class_name = self.class.to_s.downcase
          ext = /[^:]*$/.match(class_name)
          raise NoGemError.new("To use .#{ext} files, type: `gem install #{gem}`")
        end
      end

      def build_scope(page, data)
        # Page is the scope
        scope = page.get_binding
        scope_object = eval("self", scope)

        # Inherit local vars
        scope_object.send(:instance_variable_set, '@_locals', data)
        f_set_locals = data.keys.map { |k| "#{k} = @_locals[#{k.inspect}];" }.join("\n")
        eval(f_set_locals, scope)

        scope_object.instance_eval do
          def eval_block(src, &block)
            # This will let you eval something, and `yield` within that block.
            eval src, &block
          end
          get_helpers.each { |helper_class| extend helper_class }
        end

        scope
      end

      # Override me
      def evaluate(scope, data, &block)
        ""
      end
    end

    # Any filetype that is split with the -- separator
    class Parsable < Base
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

      def markup
        @markup
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
      def render(data = 0, &block)
        output = ''
        File.open(@page.filename, "r") { |f| output = f.read }
        output
      end
    end
  end
end
