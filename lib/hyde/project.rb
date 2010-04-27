module Hyde
  class Project
    include Hyde::Utils

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
      @config.send meth # SHOULD SEND AND ERROR!!
    end

    # Can throw a NotFound.
    def render( pathname )
      pathname = "index.html"  if pathname.empty?
      page = Page.new pathname, self
      page.render
    end

    def build
      raise Errno::EEXISTS  if File.exists? root(:output) and not Dir.exists? root(:output)
      Dir.mkdir root(:output)  unless Dir.exists? root(:output)

      files.each do |filename|
        mfile = force_file_open(root(:output), filename)
        mfile << render(filename)
        mfile.close
      end
    end

    # Returns a list of all URLs
    def files
      @file_list ||= Dir[File.join(root, '**', '*')].inject([]) do |a, match|
        # Make sure its the canonical name
        path = File.expand_path(match)
        file = path.gsub /^#{Regexp.escape root}\/?/, ''
        ext  = File.extname(file)[1..-1]
        
        if ignored_files.include?(path) or Dir.exists?(match)
          # pass
        elsif not get_renderer(ext).nil? # Has a renderer associated
          a << file.chomp(".#{ext}")
        else
          a << file
        end
        a
      end
    end

    def ignore_list
      @ignote_list ||= [
        root(:layouts, '**/*'),
        root(:extensions, '**/*'),
        root(:output, '**/*'),
        @config_file
      ]
    end

    def ignored_files
      @ignored_files ||= ignore_list.inject([]) { |a, spec|
        Dir[spec].each { |file| a << File.expand_path(file) }; a
      }
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
