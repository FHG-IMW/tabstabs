module TabsTabs
  module Resolutions
    module Minute
      include TabsTabs::Resolutionable
      extend self

      PATTERN = "%Y-%m-%d-%H-%M"

      def name
        :minute
      end

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.minute
      end

      def to_seconds
        1.minute
      end

      def add(ts, num)
        ts + num.minutes
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.min)
      end

    end
  end
end
