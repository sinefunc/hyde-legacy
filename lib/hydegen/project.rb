module Hydegen
  class Project

    # The root path (String).
    #   root
    #   root :layouts
    #   root :site, 'blah'
    def root(*args)
      where = ''
      where = send("#{args.shift.to_s}_path")  if args[0].class == Symbol
      path = args
      File.join [@root, where, path].reject(&:empty?)
    end

    # The filename of the configuration file, relative to the project root.
    attr :config_file

    # The configuration k/v storage (Hash)
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

    # Can throw a NotFound.
    def render( pathname )
      pathname = "index.html"  if pathname.empty?
      page = Page.new pathname, self
      page.render
    end

    def build
      # Can error
      Dir.mkdir @site_root  unless File.exists? @site_root
      files.each do |file|
        output = File.join(root, site_path, file)
        # mkdir and open output
        # render file
      end
    end

    # Returns a list of all URLs
    def files
      @file_list ||= Dir[File.join(root, '**', '*')].inject([]) do |a, match|
        # Make sure its the canonical name
        path = File.expand_path(match)
        file = path.gsub /^#{Regexp.escape root}\/?/, ''
        ext  = File.extname(file)[1..-1]
        
        ignore_list = [
          root(:layouts, '**/*'),
          root(:extensions, '**/*'),
          root(:output, '**/*'),
          @config_file
        ]

        ignore_files = ignore_list.inject([]) { |a, spec|
          Dir[spec].each { |file| a << File.expand_path(file) }; a
        }

        if ignore_files.include?(path) or Dir.exists?(match)
          # pass
        elsif not get_renderer(ext).nil? # Has a renderer associated
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
        'site_path'       => '_site',
        'output_path'     => '_output'
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
