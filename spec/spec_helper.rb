require "rubygems"
require "tabs_tabs"
require "pry"
require "timecop"

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
  	TabsTabs::Resolution.reset_default_resolutions
    TabsTabs::Storage.del_by_prefix("")
  end

  config.after(:each) do
    Timecop.return
  end
end
