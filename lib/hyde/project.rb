module Hyde
  # TODO: This class is growing... time to refactor
  class Project
    include Hyde::Utils

    # The filename of the configuration file, relative to the project root. (String)
    #
    attr :config_file

    # The configuration k/v storage (OStruct)
    #
    attr_accessor :config

    # The root path (String).
    #
    # @example
    #   root
    #   root :layouts
    #   root :site, 'blah'
    #
    def root(*args)
      where = ''
      where = @config.send("#{args.shift.to_s}_path")  if args[0].class == Symbol
      path = args
      File.expand_path(File.join [@root, where, path].reject(&:empty?))
    end

    # Can raise a NoRootError
    #
    def initialize(root = Dir.pwd)
      @config = OStruct.new defaults
      @root, @config_file = find_root_from root
      @config.merge! YAML::load_file(@config_file)

      # Check for version
      raise IncompatibleError, "This project requires at least Hyde v#{@config.hyde_requirement}." \
        unless @config.hyde_requirement.nil? or \
          ::Hyde.compatible_with?(@config.hyde_requirement)

      load_extensions
    end

    # Returns an object in the project.
    # Can be a page, layout, template...
    #
    # @example
    #   @project['index.html']
    #   @project['default', :Layout]
    #   @project['widgets/sidebar', :Partial]
    #
    def [](name, default_class=Page)
      default_class = ::Hyde.const_get(default_class)  if default_class.is_a? Symbol
      Hyde::Page[name, self, default_class]
    end

    # Writes the output files.
    # @param
    #   ostream    - (Stream) Where to send the messages
    #
    def build(ostream = nil)
      if File.exists? root(:output)
        raise Errno::EEXISTS  unless File.directory? root(:output)
      else
        Dir.mkdir root(:output)
      end

      begin
        files.each do |path|
          ostream << " * #{@config.output_path}/#{path}\n"  if ostream

          begin
            rendered = self[path].render
            force_file_open(root(:output, path)) { |file| file << rendered }

          rescue RenderError => e
            ostream << " *** Error: #{e.to_s}".gsub("\n", "\n *** ") << "\n"
          end
        end

      rescue NoGemError => e
        ostream << " *** Error: #{e.message}\n"
      end
    end

    # Returns a list of all URL paths
    #
    def files
      @file_list = Dir[File.join(root(:site), '**', '*')].inject([]) do |a, match|
        # Make sure its the canonical name
        path = File.expand_path(match)
        file = path.gsub /^#{Regexp.escape root(:site)}\/?/, ''
        ext  = File.extname(file)[1..-1]
        
        if ignored_files.include?(path) or File.directory?(match)
          # pass
        elsif not get_renderer(ext).nil? # Has a renderer associated
          fname = file.chomp(".#{ext}")
          fname += get_renderer(ext).default_ext  unless File.basename(fname).include?('.')
          a << fname
        else
          a << file
        end
        a
      end
    end

    # Returns a list of file specs to be excluded from processing.
    # @see {#ignored_files}
    #
    def ignore_list
      @ignore_list ||= [
        root(:layouts, '**/*'),
        root(:extensions, '**/*'),
        root(:output, '**/*'),
        @config_file
      ].uniq
    end

    # Returns a list of ignored files based on the {ignore_list}.
    # TODO: This is innefficient... do it another way
    #
    def ignored_files
      @ignored_files ||= ignore_list.inject([]) do |a, spec|
        Dir[spec].each { |file| a << File.expand_path(file) }; a
      end
    end

    def self.config_filenames
      ['_config.yml', 'hyde.conf', '.hyderc']
    end

    protected

    # Looks for the hyde config file to determine the project root.
    #
    def find_root_from(start)
      check = File.expand_path(start)
      ret = nil
      while ret.nil?
        # See if any of these files exist
        self.class.config_filenames.each do |config_name|
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

    # Loads the ruby files in the extensions folder
    #
    def load_extensions
      # Load the init.rb file
      require(root 'init.rb')  if File.exists?(root 'init.rb')

      # Load the gems in the config file
      @config.gems.each { |gem| require gem }

      # Load the extensions
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

    def defaults
      { 'layouts_path'    => 'layouts',
        'extensions_path' => 'extensions',
        'partials_path'   => 'layouts',
        'site_path'       => 'site',
        'output_path'     => 'public',
        'port'            => 4833,
        'gems'            => []
      }
    end

    # Returns the renderer associated with the given file extension.
    #
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
