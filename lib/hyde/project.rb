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
      File.expand_path(File.join [@root, where, path].reject(&:empty?))
    end

    # The filename of the configuration file, relative to the project root.
    attr :config_file

    # The configuration k/v storage (Hash)
    attr_accessor :config

    def initialize( root = Dir.pwd )
      @config = OStruct.new defaults

      # find_root
      @root = root
      @config_file ||= "#{@root}/_config.yml"

      @config.merge! YAML::load_file(@config_file)  if File.exists? @config_file
    end

    def method_missing(meth, *args, &blk)
      raise NoMethodError, "No method `#{meth}`"  unless @config.include?(meth)
      @config.send meth
    end

    # Returns a page in a certain URL path.
    # @return {Page} or a subclass of it
    def get_page(path)
      path = "index.html"  if path.empty?
      Page.create path, self
    end

    def get_layout(path)
      Layout.create path, self
    end

    # Can throw a NotFound.
    def render(path)
      get_page(path).render
    end

    # Writes the output files.
    # @param
    #   ostream    - (Stream) Where to send the messages
    def build(ostream = nil)
      raise Errno::EEXISTS  if File.exists? root(:output) and not Dir.exists? root(:output)
      Dir.mkdir root(:output)  unless Dir.exists? root(:output)

      begin
        files.each do |path|
          ostream << " * #{output_path}/#{path}\n"  if ostream
          mfile = force_file_open(root(:output, path))
          mfile << render(path)
          mfile.close
        end
      rescue NoGemError => e
        ostream << "Error: #{e.message}\n"
      end
    end

    # Returns a list of all URL paths
    def files
      @file_list ||= Dir[File.join(root(:site), '**', '*')].inject([]) do |a, match|
        # Make sure its the canonical name
        path = File.expand_path(match)
        file = path.gsub /^#{Regexp.escape root(:site)}\/?/, ''
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
      @ignore_list ||= [
        root(:layouts, '**/*'),
        root(:extensions, '**/*'),
        root(:output, '**/*'),
        @config_file
      ]
    end

    # Returns a list of ignored files.
    # TODO: This is innefficient... do it another way
    def ignored_files
      @ignored_files ||= ignore_list.inject([]) { |a, spec|
        Dir[spec].each { |file| a << File.expand_path(file) }; a
      }
    end

    protected
    def defaults
      { 'layouts_path'    => 'layouts',
        'extensions_path' => 'extensions',
        'site_path'       => 'site',
        'output_path'     => 'public'
      }
    end

    # Returns the renderer associated with the given file extension.
    def get_renderer(name)
      begin
        class_name = name.to_s.capitalize.to_sym
        renderer = ::Hyde::Renderers.const_get(class_name)
      rescue NameError
        renderer = nil
      end
      renderer
    end
  end
end
