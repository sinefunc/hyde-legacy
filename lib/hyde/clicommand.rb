module Hyde
  class CLICommand
    @@description = nil

    def self.ostream
      STDERR
    end

    def self.log(str)
      ostream << str << "\n"
    end

    def self.help
      log "No help for this command."
    end

    def self.lib_path
      @@lib_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
    end

    def self.project
      begin
        Hyde::Project.new
      rescue NoRootError
        ostream << "No Hyde config file found. (looking for: hyde.conf, _config.yml)\n"
        exit
      end
    end

    def self.desc(str)
      class_eval %{
        def self.description
          "#{str.gsub('\"','\\\"')}"
        end
      }
    end

    def self.description
      ""
    end
  end
end
