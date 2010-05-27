require 'ostruct'

module Hyde
  class OStruct < OpenStruct
    def merge!(hash)
      hash.each_pair { |key, value| self.send "#{key.to_s}=".to_sym, value }
    end

    def include?(key)
      @table.keys.include? key
    end
  end
end
