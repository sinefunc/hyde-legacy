require 'rubygems'
require 'test/unit'
require 'contest'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'hyde'

class Test::Unit::TestCase
  include Hyde::Utils
  def assert_same_file(a, b)
    assert same_file?(a, b)
  end
end
