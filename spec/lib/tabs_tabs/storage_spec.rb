require "spec_helper"

describe TabsTabs::Storage do
  context "#redis" do
    it "should return the configured Redis" do
      expect(subject.redis).to eq(TabsTabs::Config.redis)
    end
  end

  context "#tabs_key" do
    after do
      TabsTabs::Config.prefix = nil
    end

    it "should add prefix if configued" do
      TabsTabs::Config.prefix = "myapp"
      expect(subject.tabs_key("key")).to eq("tabstabs:myapp:key")
    end

    it "should not add prefix if not there" do
      expect(subject.tabs_key("key")).to eq("tabstabs:key")
    end
  end

  context "with stubbed redis" do

    let(:stubbed_redis) { double("redis").as_null_object }

    before do
      allow(subject).to receive(:redis).and_return(stubbed_redis)
      allow(subject).to receive(:tabs_key).at_least(:once).and_call_original
    end

    it "#exists calls exists with the expected key" do
      subject.exists("foo")
      expect(stubbed_redis).to have_received(:exists).with("tabstabs:foo")
    end

    it "#expireat calls expireat with expected key and timestamp" do
      subject.expireat("foo", 1234)
      expect(stubbed_redis).to have_received(:expireat).with("tabstabs:foo", 1234)
    end

    it "#ttl calls ttl with expected key" do
      subject.ttl("foo")
      expect(stubbed_redis).to have_received(:ttl).with("tabstabs:foo")
    end

    it "#get calls get with expected key" do
      subject.get("foo")
      expect(stubbed_redis).to have_received(:get).with("tabstabs:foo")
    end

    it "#mget receives prefixed keys" do
      subject.mget("foo", "bar")
      expect(stubbed_redis).to have_received(:mget).with("tabstabs:foo", "tabstabs:bar")
    end

    it "#set calls set with the expected key and arg" do
      subject.set("foo", "bar")
      expect(stubbed_redis).to have_received(:set).with("tabstabs:foo", "bar")
    end

    it "#del" do
      subject.del("foo")
      expect(stubbed_redis).to have_received(:del).with("tabstabs:foo")
    end

    it "#del_by_prefix" do
      allow(stubbed_redis).to receive(:keys).and_return(["foo:a", "foo:b"])
      subject.del_by_prefix("foo")
      expect(stubbed_redis).to have_received(:del).with("foo:a", "foo:b")
    end

    it "#incr" do
      subject.incr("foo")
      expect(stubbed_redis).to have_received(:incr).with("tabstabs:foo")
    end

    it "#rpush" do
      subject.rpush("foo", "bar")
      expect(stubbed_redis).to have_received(:rpush).with("tabstabs:foo", "bar")
    end

    it "#sadd" do
      subject.sadd("foo", "bar", "baz")
      expect(stubbed_redis).to have_received(:sadd).with("tabstabs:foo", "bar", "baz")
    end

    it "#smembers" do
      subject.smembers("foo")
      expect(stubbed_redis).to have_received(:smembers).with("tabstabs:foo")
    end

    it "#smembers_all" do
      allow(stubbed_redis).to receive(:pipelined).and_yield
      subject.smembers_all("foo", "bar")
      expect(stubbed_redis).to have_received(:smembers).with("tabstabs:foo")
      expect(stubbed_redis).to have_received(:smembers).with("tabstabs:bar")
    end

    it "#sismember" do
      subject.sismember("foo", "bar")
      expect(stubbed_redis).to have_received(:sismember).with("tabstabs:foo", "bar")
    end

    it "#hget" do
      subject.hget("foo", "bar")
      expect(stubbed_redis).to have_received(:hget).with("tabstabs:foo", "bar")
    end

    it "#hset" do
      subject.hset("foo", "bar", "baz")
      expect(stubbed_redis).to have_received(:hset).with("tabstabs:foo", "bar", "baz")
    end

    it "#hdel" do
      subject.hdel("foo", "bar")
      expect(stubbed_redis).to have_received(:hdel).with("tabstabs:foo", "bar")
    end

    it "#hkeys" do
      subject.hkeys("foo")
      expect(stubbed_redis).to have_received(:hkeys).with("tabstabs:foo")
    end

    it "#hincrby" do
      subject.hincrby("foo", "bar", 42)
      expect(stubbed_redis).to have_received(:hincrby).with("tabstabs:foo", "bar", 42)
    end

    it "#hgetall" do
      subject.hgetall("foo")
      expect(stubbed_redis).to have_received(:hgetall).with("tabstabs:foo")
    end

  end
end
