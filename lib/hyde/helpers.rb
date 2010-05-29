module Hyde
  module Helpers
    def partial(partial_path, args = {})
      locals = args[:locals].nil? ? args : args[:locals] # Legacy

      p = project[partial_path.to_s, :Partial]
      p.render locals
    end

    def content_for(key, &block)
      content_blocks[key.to_sym] = block
    end

    def yield_content(key, *args)
      block = content_blocks[key.to_sym]
      return ''  if block.nil?

      if respond_to?(:block_is_haml?) && block_is_haml?(block)
        capture_haml *args, &block
      else
        block.call *args
      end
    end

  protected
    def content_blocks
      @@content_blocks ||= Hash.new { |h, k| h[k] = [] }
    end
  end
end
