module Hyde
  module Helpers
    def partial(partial_path, locals = {})
      begin
        p = project[partial_path.to_s, :Partial]
        p.referrer = self.referrer
        p.render locals
      rescue ::Hyde::NotFound
        "<!-- Can't find #{partial_path.to_s} -->"
      end
    end

    def content_for(key, &block)
      content_blocks[key.to_sym] = block
    end

    def has_content?(key)
      content_blocks.keys.include? key.to_sym
    end

    def yield_content(key, *args)
      block = content_blocks[key.to_sym]
      return ''  if block.nil?

      if respond_to?(:block_is_haml?) && block_is_haml?(block)
        capture_haml *args, &block
      elsif block.is_a? Proc
        block.call *args
      elsif block_given?
        yield
      else
        ''
      end
    end

  protected
    def content_blocks
      @@content_blocks ||= Hash.new
      @@content_blocks[referrer.to_sym] ||= Hash.new { |h, k| h[k] = [] }
    end
  end
end
