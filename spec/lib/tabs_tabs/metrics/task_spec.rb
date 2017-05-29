require "spec_helper"

describe TabsTabs::Metrics::Task do

  let(:metric) { TabsTabs.create_metric("foo", "task") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }
  let(:token_1) { "aaaa" }
  let(:token_2) { "bbbb" }
  let(:token_3) { "cccc" }

  describe ".start" do

    let(:token) { double(:token) }
    let(:time) { Time.now }

    it "calls start on the given token" do
      expect(TabsTabs::Metrics::Task::Token).to receive(:new).with(token_1, "foo").and_return(token)
      expect(token).to receive(:start)
      metric.start(token_1)
    end

    it "passes through the specified timestamp" do
      allow(TabsTabs::Metrics::Task::Token).to receive(:new).and_return(token)
      expect(token).to receive(:start).with(time)
      metric.start(token_1, time)
    end

  end

  describe ".complete" do

    let(:token) { double(:token) }
    let(:time) { Time.now }

    it "calls complete on the given token" do
      expect(TabsTabs::Metrics::Task::Token).to receive(:new).with(token_1, "foo").and_return(token)
      expect(token).to receive(:complete)
      metric.complete(token_1)
    end

    it "passes through the specified timestamp" do
      allow(TabsTabs::Metrics::Task::Token).to receive(:new).and_return(token)
      expect(token).to receive(:complete).with(time)
      metric.complete(token_1, time)
    end

    it "raises an UnstartedTaskMetricError if the metric has not yet been started" do
      expect { metric.complete("foobar") }.to raise_error(TabsTabs::Metrics::Task::UnstartedTaskMetricError)
    end

  end

  describe ".stats" do

    it "returns zeroes across the board for no stats" do
      stats = metric.stats((now - 5.minutes)..(now + 5.minutes), :minute)

      expect(stats.started_within_period).to eq 0
      expect(stats.completed_within_period).to eq 0
      expect(stats.started_and_completed_within_period).to eq 0
      expect(stats.completion_rate).to eq 0.0
      expect(stats.average_completion_time).to eq 0.0
    end

    it "returns the expected value" do
      Timecop.freeze(now)
      metric.start(token_1)
      metric.start(token_2)
      Timecop.freeze(now + 2.minutes)
      metric.complete(token_1)
      metric.start(token_3)
      Timecop.freeze(now + 3.minutes)
      metric.complete(token_3)
      stats = metric.stats((now - 5.minutes)..(now + 5.minutes), :minute)

      expect(stats.started_within_period).to eq 3
      expect(stats.completed_within_period).to eq 2
      expect(stats.started_and_completed_within_period).to eq 2
      expect(stats.completion_rate).to eq 0.18182
      expect(stats.average_completion_time).to eq 1.5
    end

    it "returns the expected value for a week" do
      Timecop.freeze(now)
      metric.start(token_1)
      metric.start(token_2)
      Timecop.freeze(now + 1.week)
      metric.complete(token_1)
      metric.start(token_3)
      Timecop.freeze(now + 3.weeks)
      metric.complete(token_3)
      stats = metric.stats((now - 5.weeks)..(now + 5.weeks), :week)

      expect(stats.started_within_period).to eq 3
      expect(stats.completed_within_period).to eq 2
      expect(stats.started_and_completed_within_period).to eq 2
      expect(stats.completion_rate).to eq 0.18182
      expect(stats.average_completion_time).to eq 1.5
    end

  end

end
