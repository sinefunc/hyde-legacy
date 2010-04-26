require 'helper'

class TestHyde < Test::Unit::TestCase
  def setup
    @project = get_project 'default'
  end

  def get_project(site)
    Hydegen::Project.new fixture(site)
  end

  def fixture(site)
    File.dirname(__FILE__) + '/fixtures/' + site
  end

  should "Do things" do
    @project.render 'yes.html'
    @project.render 'foo.html'
  end

  should "recognize not found" do
    assert_raises Hydegen::NotFound do
      @project.render 'garbage.html'
    end
  end

  should "use layouts" do
    output = @project.render 'layout_test.html'
    assert_match /This is the meta title/, output
    assert_match /<!-- \(default layout\) -->/, output
  end

  should "list the project files properly" do
    files = @project.files
    assert files.include? 'index.html'
    assert files.include? 'about/index.html'
    assert files.include? 'layout_test.html'
    assert !files.include?('about')
    assert !files.include?('about/')
    assert !files.include?('layout_test.html.haml')
    puts files
  end
end
