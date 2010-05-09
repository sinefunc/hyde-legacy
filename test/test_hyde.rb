require 'helper'

class TestHyde < Test::Unit::TestCase
  def setup(site = 'default')
    @project = get_project site
  end

  should "return the right paths" do
    root_path = fixture 'default'
    assert_same_file root_path, @project.root
    assert_same_file File.join(root_path, 'layouts'), \
                 @project.root(:layouts)
    assert_same_file File.join(root_path, 'layouts', 'abc'), \
                 @project.root(:layouts, 'abc')
    assert_same_file File.join(root_path, 'layouts', 'abc'), \
                 @project.root('layouts', 'abc')
  end

  should "Do things" do
    @project.render 'yes.html'
    @project.render 'foo.html'
  end

  should "recognize not found" do
    assert_raises Hyde::NotFound do
      @project.render 'garbage.html'
    end
  end

  should "load extensions" do
    begin
      CustomExtensionClass # Defined in the site's extensions/custom/custom.rb
    rescue NameError
      flunk "Extension wasn't loaded"
    end
  end

  should "use layouts" do
    output = @project.render 'layout_test.html'
    assert_match /This is the meta title/, output
    assert_match /<!-- \(default layout\) -->/, output
  end

  should "account for index.html" do
    home_output = @project.render('index.html')
    assert_equal home_output, @project.render('/')
    assert_equal home_output, @project.render('/index.html')

    about_output = @project.render('/about/index.html')
    assert_equal about_output, @project.render('/about')
    assert_equal about_output, @project.render('/about/')
  end

  should "get types right" do
    page = @project.get_page('index.html')
    assert page.is_a? Hyde::Page

    layout = Hyde::Layout.create 'default', @project
    assert layout.is_a? Hyde::Layout
    assert layout.is_a? Hyde::Page
  end

  should "list the project files properly" do
    files = @project.files
    assert files.include? 'index.html'
    assert files.include? 'about/index.html'
    assert files.include? 'layout_test.html'
    assert !files.include?('about')
    assert !files.include?('about/')
    assert !files.include?('_config.yml')
    assert !files.include?('layout/default')
    assert !files.include?('layout/default.haml')
    assert !files.include?('layout_test.html.haml')
  end
end
