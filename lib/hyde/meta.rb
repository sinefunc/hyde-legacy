module Hyde
  class Meta < OStruct
    attr_reader :page

    def initialize(page)
      @page = page
      super nil
    end

    def merge(custom)
      @table.merge custom
    end

    def layout=(value)
      super value
      @page.layout = @page.project[value, :Layout]
    end
  end
end
