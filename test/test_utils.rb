require 'helper'

class TestUtils < Test::Unit::TestCase
  def setup
    @original_pwd = Dir.pwd
    @pwd = File.join(@original_pwd, 'test')
    Dir.chdir @pwd
  end

  def teardown
    system 'rm -rf aaa'
    system 'rm -rf bbb'
    Dir.chdir @original_pwd
  end

  should "mkdir_p" do
    mkdir_p @pwd, 'aaa/bbb/ccc'
    assert Dir.exists? 'aaa'
    assert Dir.exists? 'aaa/bbb'
    assert Dir.exists? 'aaa/bbb/ccc'
  end

  should "force_file_open" do
    f = force_file_open @pwd, 'bbb/ccc/test.txt'
    assert Dir.exists? 'bbb'
    assert Dir.exists? 'bbb/ccc'
    assert File.exists? 'bbb/ccc/test.txt'
  end
end
