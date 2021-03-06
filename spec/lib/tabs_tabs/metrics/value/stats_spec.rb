require "spec_helper"

describe TabsTabs::Metrics::Value::Stats do

  let(:period) { (Time.now - 2.days..Time.now) }
  let(:resolution) { :hour }
  let(:values) do
    [
      { "timestamp" => Time.now - 30.hours, "count" => 10, "sum" => 145, "min" => 11, "max" => 204, "avg" => 14.5 },
      { "timestamp" => Time.now - 20.hours, "count" => 15, "sum" => 288, "min" => 10, "max" => 199, "avg" => 19.2 },
      { "timestamp" => Time.now - 10.hours, "count" => 25, "sum" => 405, "min" => 12, "max" => 210, "avg" => 16.2 }
    ]
  end
  let(:stats) { TabsTabs::Metrics::Value::Stats.new(period, resolution, values) }

  it "is enumerable" do
    expect(stats).to respond_to :each
    expect(TabsTabs::Metrics::Value::Stats.ancestors).to include Enumerable
  end

  it "#count returns the total count for the entire set" do
    expect(stats.count).to eq 50
  end

  it "sum returns the sum for the entire set" do
    expect(stats.sum).to eq 838
  end

  it "min returns the min for the entire set" do
    expect(stats.min).to eq 10
  end

  it "max returns the max for the entire set" do
    expect(stats.max).to eq 210
  end

  it "avg returns the average for the entire set" do
    expect(stats.avg).to eq 16.76
  end

  it "avg returns 0 if set is empty" do
    stats = TabsTabs::Metrics::Value::Stats.new(period, resolution, [])
    expect(stats.avg).to be_zero
  end

  context "override decimal precision" do
    before do
      @precision = TabsTabs.config.decimal_precision
      TabsTabs.config.decimal_precision = 1
    end

    after do
      TabsTabs.config.decimal_precision = @precision
    end

    it "allows you to override decimal precision" do
      expect(stats.avg).to eq 16.8
    end
  end

end
