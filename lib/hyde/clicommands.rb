module Hyde
  module CLICommands
    extend self

    def get_controller(str)
      if ['-v', '--version'].include? str
        controller = Hyde::CLICommands::Version
      elsif ['-h', '-?', '--help'].include? str
        controller = Hyde::CLICommands::Help
      else
        begin
          class_name = str.downcase.capitalize.to_sym
          controller = Hyde::CLICommands.const_get(class_name)
        rescue NameError
          STDERR << "Unknown command: #{str}\n"
          STDERR << "Type `hyde` for a list of commands.\n"
          exit
        end
      end
      controller
    end

    class Version < CLICommand
      hidden true
      def self.run(*a)
        out "Hyde version #{Hyde.version}"
      end
    end

    class Help < CLICommand
      hidden true

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
          unless klass.hidden?
            puts "  #{name}%s#{klass.description}" % [' ' * (20-name.size)]
          end
        end

        log ""
        log "  -h, --help          Prints this help screen"
        log "  -v, --version       Show version and exit"
        log ""
        log "For more info on a command, type `hyde --help <command>`."
      end
    end

    class Build < CLICommand
      desc "Builds the HTML files"
      def self.run(*a)
        project.build ostream
      end
    end
    
    class Start < CLICommand
      desc "Starts the local webserver"
      def self.run(*a)
        project
        system "ruby \"%s\"" % [File.join(lib_path, 'hyde', 'sinatra', 'init.rb')]
      end

      def self.help
        port = project.config.port
        log "Usage: hyde start"
        log ""
        log "This command starts the local webserver. You may then be able to"
        log "see your site locally by visiting the URL:"
        log ""
        log "   http://127.0.0.1:#{port}"
        log ""
        log "You may shut the server down by pressing Ctrl-C."
      end
    end

    class Console < CLICommand
      desc "Starts a console"

      def self.run(*a)
        path = File.join(Hyde::LIB_PATH, 'hyde_misc', 'console.rb')
        cmd = "irb -r\"#{path}\""
        system cmd
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
