require 'rubygems'
require 'sinatra/base'
require "logger"

$:.unshift File.dirname(__FILE__) + "/.."
require 'hyde'

class Main < Sinatra::Base
  configure do
    # $log = Logger.new(File.join('log', "#{Sinatra::Application.environment}.log"))
  end 

  get '/*' do
    begin
      @project ||= Hyde::Project.new
      @project.render params[:splat].to_s
    rescue Hyde::NotFound
      raise Sinatra::NotFound
    end
  end
end

Main.run!
