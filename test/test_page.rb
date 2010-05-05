require 'helper'

class TestPage < Test::Unit::TestCase
  def setup(site = 'default')
    @project = get_project site
    @page = @project.get_page 'index.html'
  end

  should "raise a method missing error" do
    assert_raises NoMethodError do
      @page.xxx
    end

    # Should NOT raise a method missing error
    @page.layout
    @page.filename
    @page.renderer
    @page.meta
    @page.layout
    @page.project
  end

  should "register the right project" do
    assert_equal @project, @page.project
  end
end
