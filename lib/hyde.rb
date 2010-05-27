require 'yaml'

module Hyde
  prefix = File.dirname(__FILE__)
  autoload :OStruct,     "#{prefix}/hyde/ostruct"
  autoload :Project,     "#{prefix}/hyde/project"
  autoload :Layout,      "#{prefix}/hyde/layout"
  autoload :Page,        "#{prefix}/hyde/page"
  autoload :PageFactory, "#{prefix}/hyde/page_factory"
  autoload :Renderer,    "#{prefix}/hyde/renderer"
  autoload :Renderers,   "#{prefix}/hyde/renderers"
  autoload :Utils,       "#{prefix}/hyde/utils"
  autoload :Meta,        "#{prefix}/hyde/meta"
  autoload :CLICommand,  "#{prefix}/hyde/clicommand"
  autoload :CLICommands, "#{prefix}/hyde/clicommands"
  autoload :Helpers,     "#{prefix}/hyde/helpers"
  autoload :Partial,     "#{prefix}/hyde/partial"

  Error = Class.new(::StandardError)
  NoGemError  = Class.new(Error)
  NotFound    = Class.new(Error)
  NoRootError = Class.new(Error) 

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
    @version ||= File.open(File.join(File.dirname(__FILE__), '..', 'VERSION')) { |f| f.read.strip }
  end
end
