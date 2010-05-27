require 'rubygems'
begin
  require 'sinatra/base'
rescue LoadError
  STDERR << "You need the sinatra gem to use `hyde start`. Type: `gem install sinatra`\n"
  exit
end

$:.unshift File.dirname(__FILE__) + "/../.."
require 'hyde'

$project = Hyde::Project.new

class Main < Sinatra::Base
  @@project ||= $project

  def self.show_start
    puts "Starting server..."
    puts "  http://127.0.0.1:4567      Homepage"
    puts "  http://127.0.0.1:4567/-    File list"
    puts ""
  end

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

      page = @@project[path]

      # Send the last modified time
      last_modified File.mtime(page.filename)
      cache_control :public, :must_revalidate, :max_age => 60

      page.render

    rescue Hyde::RenderError => e
      puts " * `#{path}` line #{e.line} error"
      puts " *** #{e.message}".gsub("\n","\n *** ")
      e.message

    rescue Hyde::NotFound
      raise Sinatra::NotFound

    end
  end
end

Main.show_start
Main.run!
