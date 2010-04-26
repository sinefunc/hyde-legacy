module Hydegen
  class Project
    attr :root, :layouts_root, :extensions_root, :site_root,
         :config_file

    attr_reader :root
    attr_accessor :config

    def initialize( root = Dir.pwd )
      @root = root
      @config_file ||= "#{@root}/_config.yml"

      @config = OStruct.new defaults
      @config.merge! YAML::load_file(@config_file)  if File.exists? @config_file
    end

    def method_missing(meth, *args, &blk)
      @config.send meth
    end

    def render( pathname )
      pathname = "index.html"  if pathname.empty?
      page = Page.new pathname, self
      page.render
    end

    def build
      # Can error
      Dir.mkdir @site_root  unless File.exists? @site_root
    end

    # Returns a list of all URLs
    def files
      @file_list ||= Dir[File.join(root, '**', '*')].inject([]) do |a, match|
        file = match.gsub /^#{Regexp.escape root}/, ''
        file.gsub! /^\/+/, ''

        ext = File.extname(file)[1..-1]

        # TODO: Ugly
        if /^#{Regexp.escape layouts_path}/.match file
          #
        elsif /^#{Regexp.escape extensions_path}/.match file
          #
        elsif /^#{Regexp.escape site_path}/.match file
          #
        elsif "#{@root}/#{file}" == @config_file
          #
        elsif Dir.exists? "#{@root}/#{file}"
          #
        elsif not get_renderer(ext).nil?
          a << file.chomp(".#{ext}")
        else
          a << file
        end
        a
      end
    end

    protected
    def defaults
      { 'layouts_path'    => '_layouts',
        'extensions_path' => '_extensions',
        'site_path'       => '_site'
      }
    end

    def get_renderer(name)
      begin
        class_name = name.to_s.capitalize.to_sym
        renderer = Renderers.const_get(class_name)
      rescue NameError
        renderer = nil
      end
      renderer
    end
  end
end
