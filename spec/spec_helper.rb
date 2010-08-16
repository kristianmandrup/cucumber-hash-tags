ENV['CUCUMBER_COLORS']=nil
require 'bundler'
Bundler.setup

begin
  require 'rspec'
  require 'rspec/autorun'
  RSpec.configure do |c|
    c.color_enabled = true
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
rescue LoadError
  require 'spec'
  require 'spec/autorun'
  Spec::Runner.configure do |c|
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
end

