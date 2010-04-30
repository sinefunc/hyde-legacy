module Hyde
  module CLICommands
    extend self

    def get_controller(str)
      begin
        class_name = str.downcase.capitalize.to_sym
        controller = Hyde::CLICommands.const_get(class_name)
      rescue NameError
        STDERR << "Unknown command: #{str}\n"
        STDERR << "Type `hyde` for a list of commands.\n"
        exit
      end
      controller
    end

    class Help < CLICommand
      desc "Shows help"

      def self.run(*a)
        if a.size == 0
          general_help
          exit
        end

        controller = CLICommands::get_controller a[0]
        controller.help
      end

      def self.general_help
        log "Usage: hyde <command> [arguments]"
        log ""
        log "Commands:"
        CLICommands.constants.each do |class_name|
          klass = CLICommands.const_get(class_name)
          name  = class_name.to_s.downcase
          puts "  #{name}%s#{klass.description}" % [' ' * (20-name.size)]
        end

        log ""
        log "For more info on a command, type `hyde help <command>`."
      end
    end

    class Build < CLICommand
      desc "Builds the HTML files"
      def self.run(*a)
        project.build ostream
      end
    end

    class Start < CLICommand
      desc "Starts the server"
      def self.run(*a)
        project
        system "ruby \"%s\"" % [File.join(lib_path, 'hyde', 'init.rb')]
      end
    end

    class Create < CLICommand
      desc "Starts a new Hyde project"
      def self.run(*a)
        unless a.size == 1
          log "Usage: hyde create <sitename>"
          exit

        else
          site_name = a[0]
          if File.directory? site_name
            log "Directory `#{site_name}` already exists!"
            exit
          end

          from = File.join(lib_path, '..', 'data', 'new_site')
          to   = File.expand_path(File.join(Dir.pwd, site_name))

          require 'fileutils'
          FileUtils.cp_r from, to

          Dir[File.join(to, '**/*')].each do |file|
            log " * %s" % [file.gsub(/^#{Regexp.escape(Dir.pwd)}\/?/, '')]
          end
        end
      end
    end
  end
end
