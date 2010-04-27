require 'yaml'

module Hydegen
  prefix = File.dirname(__FILE__)
  autoload :OStruct,    "#{prefix}/hydegen/ostruct"
  autoload :Project,    "#{prefix}/hydegen/project"
  autoload :Layout,     "#{prefix}/hydegen/layout"
  autoload :Page,       "#{prefix}/hydegen/page"
  autoload :Renderer,   "#{prefix}/hydegen/renderer"
  autoload :Renderers,  "#{prefix}/hydegen/renderers"
  autoload :Utils,      "#{prefix}/hydegen/utils"

  class NotFound < Exception
  end
end
