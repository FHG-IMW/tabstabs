module TabsTabs
  module Metrics
    class Counter
      include Storage
      include Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def increment(timestamp=Time.now)
        timestamp.utc
        TabsTabs::Resolution.all.each do |resolution|
          increment_resolution(resolution, timestamp)
        end
        increment_total
        true
      end

      def stats(period, resolution)
        timestamps = timestamp_range period, resolution
        keys = timestamps.map do |timestamp|
          storage_key(resolution, timestamp)
        end

        values = mget(*keys).map do |v|
          {
            "timestamp" => timestamps.shift,
            "count" => (v || 0).to_i
          }.with_indifferent_access
        end

        Stats.new(period, resolution, values)
      end

      def total
        (get("stat:counter:#{key}:total") || 0).to_i
      end

      def drop!
        del_by_prefix("stat:counter:#{key}")
      end

      def drop_by_resolution!(resolution)
        del_by_prefix("stat:counter:#{key}:count:#{resolution}")
      end

      def storage_key(resolution, timestamp)
        formatted_time = TabsTabs::Resolution.serialize(resolution, timestamp)
        "stat:counter:#{key}:count:#{resolution}:#{formatted_time}"
      end

      private

      def increment_resolution(resolution, timestamp)
        store_key = storage_key(resolution, timestamp)
        incr(store_key)
        TabsTabs::Resolution.expire(resolution, store_key, timestamp)
      end

      def increment_total
        incr("stat:counter:#{key}:total")
      end

    end
  end
end
