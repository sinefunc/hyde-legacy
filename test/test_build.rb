require 'helper'

class TestBuild < Test::Unit::TestCase
  def setup
    @original_pwd = Dir.pwd
    @pwd = File.join(@original_pwd, 'test','fixtures','default')
    Dir.chdir @pwd
    @project = Hyde::Project.new(@pwd)
  end

  def teardown
    Dir.chdir @original_pwd
  end

  should "build" do
    @project.build
    # Actually test shit
  end
end

