module Tabs
  module Resolutions
    module Minute
      extend self

      PATTERN = "%Y-%m-%d-%H-%M"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.minute)
      end

    end
  end
end
