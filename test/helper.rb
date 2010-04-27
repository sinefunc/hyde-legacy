require 'rubygems'
require 'test/unit'
require 'contest'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'hydegen'

class Test::Unit::TestCase
  include Hydegen::Utils

  def setup(site = 'default')
    @project = get_project site
  end

  def get_project(site)
    Hydegen::Project.new fixture(site)
  end

  def fixture(site)
    File.join File.dirname(__FILE__), 'fixtures', site
  end

  def assert_same_file(a, b)
    assert same_file?(a, b)
  end
end
