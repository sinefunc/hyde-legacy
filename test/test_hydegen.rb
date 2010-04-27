require 'helper'

class TestHyde < Test::Unit::TestCase
  should "return the right paths" do
    root_path = fixture 'default'
    assert_same_file root_path, @project.root
    assert_same_file File.join(root_path, '_layouts'), \
                 @project.root(:layouts)
    assert_same_file File.join(root_path, '_layouts', 'abc'), \
                 @project.root(:layouts, 'abc')
    assert_same_file File.join(root_path, 'layouts', 'abc'), \
                 @project.root('layouts', 'abc')
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
    assert !files.include?('_config.yml')
    assert !files.include?('layout/default')
    assert !files.include?('layout/default.haml')
    assert !files.include?('layout_test.html.haml')
    puts files
  end
end
