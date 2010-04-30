require "helper"
require 'fileutils'

class TestAllFixtures < Test::Unit::TestCase
  @@root = File.join(Dir.pwd, 'test', 'fixtures')

  def setup
    @original_pwd = Dir.pwd
  end

  def teardown
    # Remove all the generated www's
    Dir["#{@@root}/**/www"].each do |match|
      FileUtils.rm_rf match
    end
    Dir.chdir @original_pwd
  end

  def self.all_sites
    @@sites ||= Dir["#{@@root}/*"] \
      .select { |f| File.directory? f } \
      .map    { |f| File.basename(f) }
  end

  all_sites.each do |site|
    describe "Test `#{site}`" do
      should "Build #{site} properly and have identical files to the control" do
        @project = Hyde::Project.new File.join(@@root, site)
        @project.build

        unknown_root = @project.root :site
        control_root = @project.root 'www_control'

        if not File.directory? control_root
          flunk "No www_control"
        else
          @project.files.select { |f| File.directory? f }.each do |path|
            unknown = File.open(File.join(unknown_root, path)).read
            control = File.open(File.join(control_root, path)).read

            assert_equal control, unknown
          end
        end
      end
    end
  end
end
