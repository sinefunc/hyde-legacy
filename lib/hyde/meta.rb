module Hyde
  class Meta < OStruct
    attr_reader :page

    def initialize(page)
      @page = page
      super nil
    end

    def |(data)
      # TODO: Consider OStruct here?
      @table.merge data  #if data.is_a? Hash
    end

    def layout=(value)
      super value
      @page.layout = @page.project[value, :Layout]
      @page.layout.referrer = page.referrer
    end
  end
end
