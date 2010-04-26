require 'rubygems'
require 'sinatra/base'
require "logger"

$:.unshift File.dirname(__FILE__) + "/.."
require 'hydegen'

class Main < Sinatra::Base
  configure do
    # $log = Logger.new(File.join('log', "#{Sinatra::Application.environment}.log"))
  end 

  get '/*' do
    begin
      @project ||= Hydegen::Project.new
      @project.render params[:splat].to_s
    rescue Hydegen::NotFound
      raise Sinatra::NotFound
    end
  end
end

Main.run!
