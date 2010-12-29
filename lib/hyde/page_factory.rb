module Hyde
  class PageFactory
    # Creates a Page with the right class, as defined in the Page's metadata.
    #
    # Params:
    #   path   - A path, or a filename
    #
    def self.create(path, project, def_page_class = Page)
      # Remove prefix
      path.gsub!(project.root(:site), '')
      path.gsub!(/^\/+/, '')

      # Try: "file.html" => "file.html", "file" [autoguess], "file/index.html"
      ext = File.extname(path)
      begin
        do_create path, project, def_page_class
      rescue NotFound
        begin
          do_create "#{path.chomp(ext)}", project, def_page_class
        rescue NotFound
          do_create "#{path}/index.html".squeeze('/'), project, def_page_class
        end
      end
    end

    def self.do_create(path, project, def_page_class = Page)
      info = get_page_info(path, project, def_page_class)
      page_class = info[:page_class]
      page = page_class.new(path, project, info[:renderer], info[:filename])

      # What if it wants to be a different class?
      if page.meta.type
        begin
          klass = Hyde.const_get(page.meta.type.to_sym)
          page  = klass.new(path, project, info[:renderer], info[:filename])
        rescue NameError #pass
        end
      else
        page
      end
    end

    protected

    # Returns the renderer, filename, page class
    def self.get_page_info(path, project, page_class)
      renderer = nil
      filename = page_class.get_filename(path, project)

      if File.directory? filename
        raise NotFound, "`#{path}` is a directory, not a file"

      elsif File.exists? filename
        ext = File.extname(filename)[1..-1]
        renderer = Hyde::Renderer.get(ext)

      else
        # Look for the file
        matches = Dir["#{filename}.*"]
        if matches.empty?
          raise NotFound, "Can't find `#{path}{,.*}` -- #{filename}"
        end

        # Check for a matching renderer
        exts = []
        matches.each do |match|
          begin
            ext      = File.extname(match)[1..-1].capitalize.to_sym
            exts     << File.extname(match)
            r_class  = Hyde::Renderers.const_get(ext) # .get(ext, nil)
            renderer ||= r_class
            filename = match
          rescue NoMethodError
            # pass
          rescue NameError # Renderer not found
            # pass
          end
        end

        raise NotFound, "No matching (#{exts.join(", ")}) renderers found for `#{path}`" \
          if renderer.nil?
      end

      { :renderer   => renderer,
        :filename   => filename,
        :page_class => page_class
      }
    end
  end
end
