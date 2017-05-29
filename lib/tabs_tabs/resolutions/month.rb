module TabsTabs
  module Resolutions
    module Month
      include TabsTabs::Resolutionable
      extend self

      PATTERN = "%Y-%m"

      def name
        :month
      end

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.month
      end

      def to_seconds
        1.month
      end

      def add(ts, num)
        ts + num.months
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month)
      end

    end
  end
end
