require 'ostruct'

module Hyde
  class OStruct < OpenStruct
    def merge!(hash)
      hash.each_pair { |k, v| self.set!(k, v) }
    end

    def include?(key)
      @table.keys.include? key
    end

    protected
    def set!(key, value)
      self.send "#{key.to_s}=".to_sym, value
    end
  end
end
