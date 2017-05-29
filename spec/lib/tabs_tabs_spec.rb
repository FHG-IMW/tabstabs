require "spec_helper"

describe TabsTabs do
  include TabsTabs::Storage

  describe ".create_metric" do

    it "raises an error if the type is invalid" do
      expect { TabsTabs.create_metric("foo", "foobar") }.to raise_error(TabsTabs::UnknownTypeError)
    end

    it "raises an error if the metric already exists" do
      TabsTabs.create_metric("foo", "counter")
      expect { TabsTabs.create_metric("foo", "counter") }.to raise_error(TabsTabs::DuplicateMetricError)
    end

    it "returns a Counter metric if 'counter' was the specified type" do
      expect(TabsTabs.create_metric("foo", "counter")).to be_a_kind_of(TabsTabs::Metrics::Counter)
    end

    it "returns a Value metric if 'value' was the specified type" do
      expect(TabsTabs.create_metric("foo", "value")).to be_a_kind_of(TabsTabs::Metrics::Value)
    end

    it "adds the metric's key to the list_metrics" do
      TabsTabs.create_metric("foo", "value")
      TabsTabs.create_metric("bar", "counter")
      TabsTabs.create_metric("baz", "task")
      expect(TabsTabs.list_metrics).to include("foo")
      expect(TabsTabs.list_metrics).to include("bar")
      expect(TabsTabs.list_metrics).to include("baz")
    end

  end

  describe ".counter_total" do

    it "returns the total for a counter metric" do
      TabsTabs.increment_counter("foo")
      expect(TabsTabs.counter_total("foo")).to eq 1
    end

    it "returns the value of the block if given and the metric doesn't exist" do
      expect(TabsTabs.counter_total("foo") { 42 }).to eq 42
    end

    it "raises an UnknownMetricError if no block is given and the metric does not exist" do
      expect { TabsTabs.counter_total("foo") }.to raise_error TabsTabs::UnknownMetricError
    end

  end

  describe ".get_metric" do

    it "returns the expected metric object" do
      TabsTabs.create_metric("foo", "counter")
      expect(TabsTabs.get_metric("foo")).to be_a_kind_of(TabsTabs::Metrics::Counter)
    end

  end

  describe ".list_metrics" do

    it "returns the list_metrics of metric names" do
      TabsTabs.create_metric("foo", "counter")
      TabsTabs.create_metric("bar", "value")
      expect(TabsTabs.list_metrics).to eq(["foo", "bar"])
    end

  end

  describe ".metric_exists?" do

    it "returns true if the metric exists" do
      TabsTabs.create_metric("foo", "counter")
      expect(TabsTabs.metric_exists?("foo")).to be_truthy
    end

    it "returns false if the metric does not exist" do
      expect(TabsTabs.metric_exists?("foo")).to be_falsey
    end

  end

  describe ".drop_metric" do

    before do
      TabsTabs.create_metric("foo", "counter")
    end

    it "removes the metric from the list_metrics" do
      TabsTabs.drop_metric!("foo")
      expect(TabsTabs.list_metrics).to_not include("foo")
    end

    it "results in metric_exists? returning false" do
      TabsTabs.drop_metric!("foo")
      expect(TabsTabs.metric_exists?("foo")).to be_falsey
    end

    it "calls drop! on the metric" do
      metric = double(:metric)
      allow(TabsTabs).to receive(:get_metric).and_return(metric)
      expect(metric).to receive(:drop!)
      TabsTabs.drop_metric!("foo")
    end

  end

  describe ".drop_all_metrics" do

    it "drops all metrics" do
      TabsTabs.create_metric("foo", "counter")
      TabsTabs.create_metric("bar", "value")
      TabsTabs.drop_all_metrics!
      expect(TabsTabs.metric_exists?("foo")).to be_falsey
      expect(TabsTabs.metric_exists?("bar")).to be_falsey
    end

  end

  describe ".increment_counter" do

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      TabsTabs.create_metric("foo", "value")
      expect { TabsTabs.increment_counter("foo") }.to raise_error(TabsTabs::MetricTypeMismatchError)
    end

    it "creates the metric if it doesn't exist" do
      expect(TabsTabs.metric_exists?("foo")).to be_falsey
      expect { TabsTabs.increment_counter("foo") }.to_not raise_error
      expect(TabsTabs.metric_exists?("foo")).to be_truthy
    end

    it "calls increment on the metric" do
      metric = TabsTabs.create_metric("foo", "counter")
      allow(TabsTabs).to receive(:get_metric).and_return(metric)
      expect(metric).to receive(:increment)
      TabsTabs.increment_counter("foo")
    end

  end

  describe ".record_value" do

    it "creates the metric if it doesn't exist" do
      expect(TabsTabs.metric_exists?("foo")).to be_falsey
      expect { TabsTabs.record_value("foo", 38) }.not_to raise_error
      expect(TabsTabs.metric_exists?("foo")).to be_truthy
    end

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      TabsTabs.create_metric("foo", "counter")
      expect { TabsTabs.record_value("foo", 27) }.to raise_error(TabsTabs::MetricTypeMismatchError)
    end

    it "calls record on the metric" do
      Timecop.freeze(Time.now.utc)
      metric = TabsTabs.create_metric("foo", "value")
      allow(TabsTabs).to receive(:get_metric).and_return(metric)
      allow(metric).to receive(:record).with(42, Time.now.utc)
      TabsTabs.record_value("foo", 42)
    end

  end

  describe ".list_metrics" do

    it "lists all metrics that are defined" do
      TabsTabs.create_metric("foo", "counter")
      TabsTabs.create_metric("bar", "counter")
      TabsTabs.create_metric("baz", "counter")
      expect(TabsTabs.list_metrics).to eq(["foo", "bar", "baz"])
    end

  end

  describe ".metric_type" do

    it "returns the type of a counter metric" do
      TabsTabs.create_metric("foo", "counter")
      expect(TabsTabs.metric_type("foo")).to eq("counter")
    end

    it "returns the type of a value metric" do
      TabsTabs.create_metric("bar", "value")
      expect(TabsTabs.metric_type("bar")).to eq("value")
    end

    it "returns the type of a task metric" do
      TabsTabs.create_metric("baz", "task")
      expect(TabsTabs.metric_type("baz")).to eq("task")
    end

  end

  describe ".drop_resolution_for_metric!" do
    it "raises unknown metric error if metric does not exist" do
      expect{ TabsTabs.drop_resolution_for_metric!(:invalid, :minute) }.to raise_error(TabsTabs::UnknownMetricError)
    end

    it "raises resolution missing error if resolution not registered" do
      TabsTabs.create_metric("baz", "value")
      expect{ TabsTabs.drop_resolution_for_metric!("baz", :invalid) }.to raise_error(TabsTabs::ResolutionMissingError)
    end

    it "does not allow you to call drop_by_resolution if task metric" do
      metric = TabsTabs.create_metric("baz", "task")
      expect(metric).not_to receive(:drop_by_resolution!)
      TabsTabs.drop_resolution_for_metric!("baz", :minute)
    end

    it "drops the metric by resolution" do
      now = Time.utc(2000,1,1)
      metric = TabsTabs.create_metric("baz", "value")
      metric.record(42, now)
      TabsTabs.drop_resolution_for_metric!("baz", :minute)
      minute_key = TabsTabs::Metrics::Value.new("baz").storage_key(:minute, now)
      expect(TabsTabs::Storage.exists(minute_key)).to be_falsey
    end
  end

end
