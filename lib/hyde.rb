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

  class NotFound < Exception
  end
end
