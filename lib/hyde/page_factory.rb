module Hyde
  class PageFactory
    def self.create(path, project, def_page_class = Page)
      begin
        do_create path, project, def_page_class
      rescue NotFound
        do_create "#{path}/index.html".squeeze('/'), project, def_page_class
      rescue NotFound => e
        raise e
      end
    end

    def self.do_create(path, project, def_page_class = Page)
      info = get_page_info(path, project, def_page_class)
      page_class = info[:page_class]
      page_class.new(path, project, info[:renderer], info[:filename])
    end

    protected

    def self.get_page_info(path, project, page_class)
      renderer = nil
      filename = page_class.get_filename(path, project)

      if File.directory? filename
        raise NotFound, "`#{path} is a directory, not a file"

      elsif File.exists? filename
        renderer = Hyde::Renderer::Passthru

      else
        # Look for the file
        matches = Dir["#{filename}.*"]
        raise NotFound, "Can't find `#{path}{,.*}` -- #{filename}" \
          if matches.empty?

        # Check for a matching renderer
        exts = []
        matches.each do |match|
          begin
            ext      = File.extname(match)[1..-1].capitalize.to_sym
            exts     << File.extname(match)
            r_class  = Hyde::Renderers.const_get(ext)
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