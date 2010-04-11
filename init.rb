require 'rubygems'
require 'sinatra'

$:.unshift File.dirname(__FILE__)
require 'hyde'

class Main
  get '/*' do
    begin
      Hyde::PROJECT.render params[:splat].to_s
    rescue Hyde::NotFound
      raise Sinatra::NotFound
    end
  end
end


