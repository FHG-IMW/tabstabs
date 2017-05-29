require "spec_helper"

describe TabsTabs::Resolutionable do

  module TestResolution
    include TabsTabs::Resolutionable
    extend self

    def name
      :test
    end

    def to_seconds
      1000
    end

  end

  describe "interface exceptions" do

    ["serialize", "deserialize", "from_seconds", "add", "normalize"].each do |method|
      it "are raised when the #{method} method is not implemented" do
        expect { TestResolution.send(method) }.to raise_error(RuntimeError)
      end
    end

  end

  describe "#expire" do
    let(:expires_setting){ 1.day }

    before do
      TabsTabs::Config.register_resolution(TestResolution)
      TabsTabs::Config.set_expirations(test: expires_setting)
    end

    after do
      TabsTabs::Config.reset_expirations
      TabsTabs::Config.unregister_resolutions(:test)
    end

    it "sets the expiration for the given key" do
      now = Time.utc(2050, 1, 1, 0, 0, 0)
      TabsTabs::Storage.set("foo", "bar")
      TestResolution.expire("foo", now)
      redis_expire_date = Time.now + TabsTabs::Storage.ttl("foo")
      expire_date = now + expires_setting + TestResolution.to_seconds
      expect(redis_expire_date).to be_within(2.seconds).of(expire_date)
    end

  end

end
