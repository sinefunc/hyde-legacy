require 'rubygems'
require 'sinatra'
require "logger"

$:.unshift File.dirname(__FILE__) + "/.."
require 'hyde'

class Main
  configure do
    # $log = Logger.new(File.join('log', "#{Sinatra::Application.environment}.log"))
  end 
  
  get '/*' do
    begin
      Hyde::PROJECT.render params[:splat].to_s
    rescue Hyde::NotFound
      raise Sinatra::NotFound
    end
  end
end


