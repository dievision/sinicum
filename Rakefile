begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
Bundler::GemHelper.install_tasks

require 'rake'
require 'rdoc/task'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
Rubocop::RakeTask.new(:rubocop) do |task|
  # don't abort rake on failure
  task.fail_on_error = false
end

task default: [:spec, :rubocop]

desc "Create Sinicum plugin documentation"
task :doc do |doc|

  require 'yard'

  gem_root = File.dirname(__FILE__)

  docdir = ENV['docdir'] || File.join(gem_root, "doc")
  rm_r Dir.glob(docdir + "/*") if File.exists?(docdir)
  YARD::Rake::YardocTask.new do |t|
    t.files   = [File.join(gem_root, "lib", "**", "*.rb")]   # optional
    t.options = ['-m', 'markdown', '--protected', '-o', docdir,
      '-r', File.join(gem_root, "README.md")]
  end
  Rake::Task[:yard].invoke
end
