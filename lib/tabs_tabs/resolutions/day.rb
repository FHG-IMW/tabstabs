module TabsTabs
  module Resolutions
    module Day
      include TabsTabs::Resolutionable
      extend self

      PATTERN = "%Y-%m-%d"

      def name
        :day
      end

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.day
      end

      def to_seconds
        1.day
      end

      def add(ts, num)
        ts + num.days
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day)
      end

    end
  end
end
