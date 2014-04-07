require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/test_*.rb'
  t.verbose = true
end

desc "Run tests"
task :default => [:test, :rdoc]

desc 'Generates a coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

desc 'Generates documentation'
Rake::RDocTask.new do |rd|
  rd.title = 'Akamai::Edgegrid::HTTP'
  rd.rdoc_files.include("lib/**/*.rb")
end
