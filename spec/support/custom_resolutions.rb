module BadlyFormedResolution
  include TabsTabs::Resolutionable
  extend self
end

module WellFormedResolution
  include TabsTabs::Resolutionable
  extend self

  PATTERN = "%Y-%m-%d-%H-%M-%S"

  def name
    :seconds
  end

  def serialize(timestamp)
    timestamp.strftime(PATTERN)
  end

  def deserialize(str)
    dt = DateTime.strptime(str, PATTERN)
    self.normalize(dt)
  end

  def from_seconds(s)
    s / 1
  end

  def to_seconds
    1
  end

  def add(ts, num)
    ts + num.seconds
  end

  def normalize(ts)
    Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
  end
end
