module Hyde
  module Helpers
    def partial(partial_path, locals = {})
      begin
        p = project[partial_path.to_s, :Partial]
        p.referrer = (referrer || self)
        p.render locals

      rescue ::Hyde::NotFound
        "<!-- Can't find #{partial_path.to_s} -->"
      end
    end

    def content_for(key, &block)
      content_block[key.to_sym] = block
    end

    def has_content?(key)
      content_block.keys.include? key.to_sym
    end

    def yield_content(key, *args, &default_block)
      block = content_block[key.to_sym]

      if respond_to?(:block_is_haml?) && block_is_haml?(block)
        capture_haml *args, &block

      elsif block.respond_to?(:call)
        block.call *args

      elsif block_given? and respond_to?(:capture_haml)
        capture_haml *args, &default_block

      elsif block_given?
        yield

      else
        ''
      end
    end

  protected
    def content_block
      file_key = (referrer || self).to_sym
      @@content_blocks ||= Hash.new
      @@content_blocks[file_key] ||= Hash.new
    end
  end
end
