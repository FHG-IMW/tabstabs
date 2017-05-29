require "spec_helper"
require File.expand_path("../../../support/custom_resolutions", __FILE__)

describe TabsTabs::Config do
  context "#decimal_precision" do

  	before do
  		@precision = TabsTabs::Config.decimal_precision
  	end

  	after do
  		TabsTabs::Config.decimal_precision = @precision
  	end

  	it "should set/get the decimal precision" do
  	  TabsTabs::Config.decimal_precision = 4
  	  expect(TabsTabs::Config.decimal_precision).to eq(4)
  	end
  end

  context "#register_resolution" do
  	it "should register a resolution" do
	  	TabsTabs::Resolution.register(WellFormedResolution)
	  	expect(TabsTabs::Resolution.all).to include(:seconds)
  	end
  end

  context "#unregister_resolution" do
  	it "should unregister a resolution" do
  		TabsTabs::Resolution.unregister(:minute)
  		expect(TabsTabs::Resolution.all).to_not include(:minute)
  	end
  end

  context "#set_expirations" do

    after do
      TabsTabs::Config.reset_expirations
    end

    it "should allow multiple resolutions to be expired" do
      TabsTabs::Config.set_expirations({minute: 1.day, hour: 1.week })
      expect(TabsTabs::Config.expiration_settings[:minute]).to eq(1.day)
      expect(TabsTabs::Config.expiration_settings[:hour]).to eq(1.week)
    end

    it "should raise ResolutionMissingError if expiration passed in for invalid resolution" do
      expect{ TabsTabs::Config.set_expirations({missing_resolution: 1.day }) }
        .to raise_error(TabsTabs::ResolutionMissingError)
    end

  end

  context "#prefix" do
    it "should allow custom prefix for tabstabs keys" do
      TabsTabs::Config.prefix = "rspec"
      expect(TabsTabs::Config.prefix).to eq("rspec")
    end
  end
end
