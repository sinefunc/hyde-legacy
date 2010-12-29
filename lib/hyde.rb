require 'yaml'

module Hyde
  LIB_PATH = File.dirname(__FILE__)

  autoload :OStruct,     "#{LIB_PATH}/hyde/ostruct"
  autoload :Project,     "#{LIB_PATH}/hyde/project"
  autoload :Layout,      "#{LIB_PATH}/hyde/layout"
  autoload :Page,        "#{LIB_PATH}/hyde/page"
  autoload :PageFactory, "#{LIB_PATH}/hyde/page_factory"
  autoload :Renderer,    "#{LIB_PATH}/hyde/renderer"
  autoload :Renderers,   "#{LIB_PATH}/hyde/renderers"
  autoload :Utils,       "#{LIB_PATH}/hyde/utils"
  autoload :Meta,        "#{LIB_PATH}/hyde/meta"
  autoload :CLICommand,  "#{LIB_PATH}/hyde/clicommand"
  autoload :CLICommands, "#{LIB_PATH}/hyde/clicommands"
  autoload :Helpers,     "#{LIB_PATH}/hyde/helpers"
  autoload :Partial,     "#{LIB_PATH}/hyde/partial"

  Error = Class.new(::StandardError)
  NoGemError        = Class.new(Error)
  NotFound          = Class.new(Error)
  NoRootError       = Class.new(Error) 
  IncompatibleError = Class.new(Error)

  class RenderError < Error
    attr_accessor :message
    attr_accessor :line

    def initialize(msg, *args)
      @message = msg
      a = args.inject({}) { |a, i| a.merge! i  if i.is_a? Hash; a }
      @line = a[:line]  if a[:line]
    end

    def to_s
      @line ?
        "line #{@line}: #{@message}" :
        "#{@message}"
    end
  end

  extend self

  def version
    @version ||= begin
      v = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION')) { |f| f.read.strip }
      v = v.match(/^[0-9]+(\.[0-9]+){2}/)[0] rescue v
    end
  end

  def compatible_with?(given_version)
    Gem::Version.new(version) >= Gem::Version.new(given_version)
  end
end
