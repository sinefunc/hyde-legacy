require 'rubygems'
require 'sinatra/base'
require "logger"

$:.unshift File.dirname(__FILE__) + "/.."
require 'hyde'

class Main < Sinatra::Base
  @@project ||= Hyde::Project.new

  get '/-' do
    @@project.files.inject("") do |a, path|
      a << "<li><a href='#{path}'>#{path}</a></li>"
      a
    end
  end

  get '/*' do
    begin
      path = params[:splat][0]
      @@project.render path
    rescue Hyde::NotFound
      raise Sinatra::NotFound
    end
  end
end

Main.run!
