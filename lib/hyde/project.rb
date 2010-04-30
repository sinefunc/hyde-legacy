module Hyde
  # TODO: This class is growing... time to refactor
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

    # Can raise a NoRootError
    def initialize( root = Dir.pwd )
      @config = OStruct.new defaults
      @root, @config_file = find_root_from root
      @config.merge! YAML::load_file(@config_file)  if File.exists? @config_file
      load_extensions
    end

    def find_root_from(start)
      check = File.expand_path(start)
      ret = nil
      while ret.nil?
        # See if any of these files exist
        ['_config.yml', 'hyde.conf'].each do |config_name|
          config_file = File.join(check, config_name)
          ret ||= [check, config_file]  if File.exists? config_file
        end

        # Traverse back (die if we reach the root)
        old_check = check
        check = File.expand_path(File.join(check, '..'))
        raise NoRootError  if check == old_check
      end
      ret
    end

    def load_extensions
      @config.gems.each do |gem|
        require gem
      end

      ext_roots = Dir[root :extensions, '*'].select { |d| File.directory? d }
      ext_roots.each do |dir|
        ext = File.basename(dir)

        # Try extensions/name/name.rb
        # Try extensions/name/lib/name.rb
        ext_files = [
          File.join(dir, "#{ext}.rb"),
          File.join(dir, 'lib', "#{ext}.rb")
        ]
        ext_files.reject! { |f| not File.exists? f }
        require ext_files[0]  if ext_files[0]
      end
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
      raise Errno::EEXISTS  if File.exists? root(:output) and not File.directory? root(:output)
      Dir.mkdir root(:output)  unless File.directory? root(:output)

      begin
        continue = true
        files.each do |path|
          ostream << " * #{output_path}/#{path}\n"  if ostream
          begin
            rendered = render(path)
            mfile = force_file_open(root(:output, path))
            mfile << rendered
            mfile.close
          rescue RenderError => e
            ostream << " *** Error: #{e.message}".gsub("\n", "\n *** ") << "\n"
          end
        end
      rescue NoGemError => e
        ostream << "Error: #{e.message}\n"
      end
    end

    # Returns a list of all URL paths
    def files
      @file_list = Dir[File.join(root(:site), '**', '*')].inject([]) do |a, match|
        # Make sure its the canonical name
        path = File.expand_path(match)
        file = path.gsub /^#{Regexp.escape root(:site)}\/?/, ''
        ext  = File.extname(file)[1..-1]
        
        if ignored_files.include?(path) or File.directory?(match)
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
        'output_path'     => 'public',
        'gems'            => []
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
