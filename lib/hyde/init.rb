require 'rubygems'
require 'sinatra/base'
require "logger"

$:.unshift File.dirname(__FILE__) + "/.."
require 'hyde'

puts "Starting server..."
puts "  http://127.0.0.1:4567      Homepage"
puts "  http://127.0.0.1:4567/-    File list"
puts ""

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
      type = File.extname(path)[1..-1]
      content_type type.to_sym  if type.is_a? String
      @@project.render path
    rescue Hyde::NotFound
      raise Sinatra::NotFound
    end
  end
end

Main.run!
