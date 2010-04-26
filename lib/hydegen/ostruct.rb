require 'ostruct'

module Hydegen
  class OStruct < OpenStruct
    def merge!(hash)
      hash.each_pair { |k, v| self.set!(k, v) }
    end

    protected
    def set!(key, value)
      self.send "#{key.to_s}=".to_sym, value
    end
  end
end
