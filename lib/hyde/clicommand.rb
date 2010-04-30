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
      log "Usage: hyde #{self.to_s.downcase.split(':')[-1]}"
      log "No help for this command."
    end

    def self.lib_path
      @@lib_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
    end

    def self.project
      if $project.nil?
        log "Error: Hyde config file not found. (looking for: hyde.conf, _config.yml)"
        log "Run this command in a Hyde project directory.\nTo start a new Hyde project, type `hyde create <name>`"
        exit
      end
      $project
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
