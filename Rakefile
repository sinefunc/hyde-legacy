begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "hydeweb"
    s.authors     = ["Rico Sta. Cruz", "Sinefunc, Inc."]
    s.email       = "rico@sinefunc.com"
    s.summary     = "Website preprocessor"
    s.homepage    = "http://github.com/sinefunc/hyde"
    s.description = "Website preprocessor"
    s.add_dependency('sinatra', '>= 1.0.0')
    s.add_dependency('less', '>= 1.2.21')
    s.add_dependency('haml', '>= 2.2.20')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Hyde #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :autotest do
  system "rstakeout 'rake test' **/*.rb"
end
