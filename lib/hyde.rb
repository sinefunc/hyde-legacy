require 'yaml'

module Hyde
  prefix = File.dirname(__FILE__)
  autoload :OStruct,    "#{prefix}/hyde/ostruct"
  autoload :Project,    "#{prefix}/hyde/project"
  autoload :Layout,     "#{prefix}/hyde/layout"
  autoload :Page,       "#{prefix}/hyde/page"
  autoload :Renderer,   "#{prefix}/hyde/renderer"
  autoload :Renderers,  "#{prefix}/hyde/renderers"
  autoload :Utils,      "#{prefix}/hyde/utils"
  autoload :Scope,      "#{prefix}/hyde/scope"
  autoload :CLICommand, "#{prefix}/hyde/clicommand"
  autoload :CLICommands,"#{prefix}/hyde/clicommands"
  autoload :TemplateHelpers,"#{prefix}/hyde/template_helpers"

  Error = Class.new(::StandardError)
  RenderError = Class.new(Error)
  NoGemError  = Class.new(Error)
  NotFound    = Class.new(Error)
  NoRootError = Class.new(Error) 
end
