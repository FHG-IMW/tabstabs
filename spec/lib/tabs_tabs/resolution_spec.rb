require "spec_helper"
require File.expand_path("../../../support/custom_resolutions", __FILE__)

describe TabsTabs::Resolution do

  describe "#register" do
    it "registers a new resolution" do
      TabsTabs::Resolution.register(WellFormedResolution)
      expect(TabsTabs::Resolution.all).to include WellFormedResolution.name
    end

    context "with a custom resolution" do
      it "does not return nil" do
        expect(WellFormedResolution.serialize(Time.now)).to_not be_nil
      end

      it "gets stats for custom resolution" do
        TabsTabs::Resolution.register(WellFormedResolution)
        Timecop.freeze(Time.now)

        TabsTabs.increment_counter("foo")
        expect(TabsTabs.get_stats("foo", (Time.now - 5.seconds..Time.now), :seconds).values.size).to eq(6)
      end

      it "raises an error when method not implemented" do
        expect{BadlyFormedResolution.normalize}.to raise_error(RuntimeError)
      end

      it "disregards already registered resolutions" do
        expect { TabsTabs::Resolution.register(TabsTabs::Resolutions::Minute) }.to_not raise_error
      end
    end
  end

  describe "#unregister" do
    it "unregisters a single resolution" do
      TabsTabs::Resolution.unregister(:minute)
      expect(TabsTabs::Resolution.all).to_not include(:minute)
    end

    it "unregisters an array of resolutions" do
      TabsTabs::Resolution.unregister([:minute, :hour])
      expect(TabsTabs::Resolution.all).to_not include(:hour)
      expect(TabsTabs::Resolution.all).to_not include(:minute)
    end

    it "disregards passing in an unrecognized resolution" do
      expect { TabsTabs::Resolution.unregister(:invalid_resolution) }.to_not raise_error
    end
  end

end
