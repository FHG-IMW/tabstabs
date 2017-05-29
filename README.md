[![Build Status](https://travis-ci.org/FHG-IMW/tabstabs.svg?branch=master)](https://travis-ci.org/FHG-IMW/tabstabs)
# TabsTabs

TabsTabs  is a redis-backed metrics tracker for time-based events that supports counts, sums,
averages, and min/max, and task based stats sliceable by the minute, hour, day, week, month, and year.

This gem is a fork of [Tabs](https://github.com/devmynd/tabs). We want to keep the project alive
and compatible with resent Ruby and Rails versions.

## Installation

Add this line to your application's Gemfile:

    gem 'TabsTabs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install TabsTabs

## Usage

Metrics come in three flavors: counters, values, and tasks.

### Counter Metrics

A counter metric simply records the number of events that occur within a given timeframe.  To create a counter metric called ‘website-visits’, simply call:

```ruby
TabsTabs .create_metric("website-visits", "counter")
```

TabsTabs  will also create a counter metric automatically the first time you
increment the counter.

To increment a metric counter, simply call:

```ruby
TabsTabs .increment_counter("website-visits")
```

If you need to retroactively increment the counter for a specific
timestamp, just pass it in.

```ruby
TabsTabs .increment_counter("wibsite-visits", Time.now - 2.days)
```

To retrieve the counts for a given time period just call `TabsTabs #get_stats` with the name of the metric, a range of times defining the period for which you want stats, and the resolution at which the data should be aggregated.

```ruby
TabsTabs .get_stats("website-visits", 10.days.ago..Time.now, :hour)
```

This will return stats for the last 10 days by hour in the form of a `TabsTabs ::Metrics::Counter::Stats` object.  This object is enumerable so you can iterate through the results like so:

```ruby
results = TabsTabs .get_stats("website-visits", 10.days.ago..Time.now, :hour)
results.each { |r| puts r }

#=>
  { timestamp: 2000-01-01 00:00:00 UTC, count: 1 }
  { timestamp: 2000-01-01 01:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 02:00:00 UTC, count: 10 }
  { timestamp: 2000-01-01 03:00:00 UTC, count: 1 }
  { timestamp: 2000-01-01 04:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 05:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 06:00:00 UTC, count: 3 }
  { timestamp: 2000-01-01 07:00:00 UTC, count: 0 }
  ...
```

The results object also provides the following methods:

```ruby
results.total       #=> The count total for the given period
results.min         #=> The min count for any timestamp in the period
results.max         #=> The max count for any timestamp in the period
results.avg         #=> The avg count for timestamps in the period
results.period      #=> The timestamp range that was requested
results.resolution  #=> The resolution requested
```

Timestamps for the given period in which no events occurred will be "filled in" with a count value to make visualizations easier.

The timestamps are also normalized.  For example, in hour resolution, the minutes and seconds of the timestamps are set to 00:00.  Likewise for the week resolution, the day is set to the first day of the week.

Lastly, you can access the overall total for a counter (for all time)
using the `counter_total` method.

```ruby
TabsTabs .counter_total("website-visits") #=> 476873
```

### Value Metrics

Value metrics record a value at a point in time and calculate the min, max, avg, and sum for a given time resolution.  Creating a value metric is easy:

To record a value, simply call `TabsTabs #record_value`.

```ruby
TabsTabs .record_value("new-user-age", 32)
```

If you need to retroactively record a value for a specific
timestamp, just pass it in.

```ruby
TabsTabs .increment_counter("new-user-age", 19, Time.now - 2.days)
```

This will also create a value metric the first time, you can manually create
a metric as well:

```ruby
TabsTabs .create_metric("new-user-age", "value")
```

Retrieving the stats for a value metric is just like retrieving a counter metric.

```ruby
TabsTabs .get_stats("new-user-age", 6.months.ago..Time.now, :month)
```

This will return a `TabsTabs ::Metrics::Value::Stats` object.  Again, this
object is enumerable and encapsulates all the timestamps within the
given period.

```ruby
results = TabsTabs .get_stats("new-user-age", 6.months.ago..Time.now, :month)
results.each { |r| puts r }
#=>
  { timestamp: 2000-01-01 00:00:00, count: 9, min: 19, max: 54, sum: 226, avg: 38 }
  { timestamp: 2000-02-01 01:00:00, count: 0, min: 0, max: 0, sum: 0, avg: 0 }
  { timestamp: 2000-03-01 02:00:00, count: 2, min: 22, max: 34, sum: 180, avg: 26 }
  ...
```

The results object also provides some aggregates and other methods:

```ruby
results.count       #=> The total count of recorded values for the period
results.sum         #=> The sum of all values for the period
results.min         #=> The min value for any timestamp in the period
results.max         #=> The max value for any timestamp in the period
results.avg         #=> The avg value for timestamps in the period
results.period      #=> The timestamp range that was requested
results.resolution  #=> The resolution requested
```

### Task Metrics

Task metrics allow you to track the beginning and ending of a process.
For example, tracking a user who downloads you mobile application and
later visits your website to make a purchase.

```ruby
TabsTabs .start_task("mobile-to-purchase", "2g4hj17787s")
```

The first argument is the metric key and the second is a unique token
used to identify the given process.  You can use any string for the
token but it needs to be unique.  Use the `complete_task` method to
finish the task:

```ruby
TabsTabs .complete_task("mobile-to-purchase", "2g4hj17787s")
```

If you need to retroactively start/complete a task at a specific
timestamp, just pass it in.

```ruby
TabsTabs .start_task("mobile-to-purchase", "2g4hj17787s", Time.now - 2.days)
TabsTabs .complete_task("mobile-to-purchase", "2g4hj17787s", Time.now - 1.days)
```

Retrieving stats for a task metric is just like the other types:

```ruby
TabsTabs .get_stats("mobile-to-purchase", 6.hours.ago..Time.now, :minute)
```

This will return a `TabsTabs ::Metrics::Task::Stats` object:

```ruby
results = TabsTabs .get_stats("mobile-to-purchase", 6.hours.ago..Time.now, :minute)
results.started_within_period       #=> Number of items started in period
results.completed_within_period     #=> Number of items completed in period
results.started_and_completed_within_period  #=> Items wholly started/completed in period
results.completion_rate             #=> Rate of completion in the given resolution
results.average_completion_time     #=> Average time for the task to be completed
```

### Resolutions

When TabsTabs increments a counter or records a value it does so for each of the following "resolutions".  You may supply any of these as the last argument to the `TabsTabs #get_stats` method.

    :minute, :hour, :day, :week, :month, :year

It automatically aggregates multiple events for the same period.  For instance when you increment a counter metric, 1 will be added for each of the resolutions for the current time.  Repeating the event 5 minutes later will increment a different minute slot, but the same hour, date, week, etc.  When you retrieve metrics, all timestamps will be in UTC.

#### Custom Resolutions

If the built-in resolutions above don't work you can add your own.  All
that's necessary is a module that conforms to the following protocol:

```ruby
module SecondResolution
  include TabsTabs ::Resolutionable
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

  def add(timestamp, num_of_seconds)
    timestamp + num_of_seconds.seconds
  end

  def normalize(ts)
    Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
  end
end

```

A little description on each of the above methods:

*`name`*: unique symbol used to reference registered resolution

*`serialize`*: converts the timestamp to a string.  The return value
here will be used as part of the Redis key storing values associated
with a given metric.

*`deserialize`*: converts the string representation of a timestamp back
into an actual DateTime value.

*`from_seconds`*: should return the number of periods in the given
number of seconds.  For example, there are 60 seconds in a minute.

*`to_seconds`*: should return the number of seconds in '1' of these time periods.  For example, there are 3600 seconds in an hour.

*`add`*: should add the number of seconds in the given resolution to the
supplied timestamp.

*`normalize`*: should simply return the first timestamp for the period.
For example, the week resolution returns the first hour of the first day
of the week.

*NOTE: If you're doing a custom resolution, you should probably look into
the code a bit.*

Once you have a module that conforms to the resolution protocol you need
to register it with TabsTabs .  You can do this in one of two ways:

```ruby
tabstabs
TabsTabs ::Resolution.register(SecondResolution)

# or, you can use the config block described below
```

#### Removing a Resolution

You can also remove any resolution (custom or built-in) by calling the `unregister_resolutions` method in the config block (see config section below).  Or, you can remove manually by calling:

```ruby
TabsTabs ::Resolution.unregister(:minute, :hour)
```

### Inspecting Metrics

You can list all metrics using `list_metrics`:

```ruby
TabsTabs .list_metrics #=> ["website-visits", "new-user-age"]
```

You can check a metric's type (counter of value) by calling
`metric_type`:

```ruby
TabsTabs .metric_type("website-visits") #=> "counter"
```

And you can quickly check if a metric exists:

```ruby
TabsTabs .metric_exists?("foobar") #=> false
```

### Drop a Metric

To drop a metric, just call `TabsTabs #drop_metric`

```ruby
TabsTabs .drop_metric!("website-visits")
```

This will drop all recorded values for the metric so it may not be un-done...be careful.

To drop only a specific resolution for a metric, just call `TabsTabs #drop_resolution_for_metric!`

```ruby
TabsTabs .drop_resolution_for_metric!("website-visits", :minute)
```

Even more dangerous, you can drop all metrics...be very careful.

```ruby
TabsTabs .drop_all_metrics!
```
### Aging Out Old Metrics

You can use the expiration features to age out old metrics that may no longer be in your operational data set.  For example, you may want to keep monthly or yearly data around but the minute or day level data isn't necessary past a certain date.  You can set expirations for any resolution:

```ruby
TabsTabs .configure do |config|
  config.set_expirations(minute: 1.day, day: 1.week)
end
```

The expiration date will start counting at the beginning of the end of the given resolution.  Meaning that for a month resolution the given expiration time would start at the end of a given month.  A month resolution metric recorded in January with an expiration of 2 weeks would expire after the 2nd week of February.

*NOTE: You cannot expire task metrics at this time, only counter and
values.*

### Configuration

TabsTabs  just works out of the box. However, if you want to override the default Redis connection or decimal precision, this is how:

```ruby
TabsTabs .configure do |config|

  # set it to an existing connection
  config.redis = Redis.current

  # pass a config hash that will be passed to Redis.new
  config.redis = { :host => 'localhost', :port => 6379 }

  tabstabs
  tabstabs
  config.prefix = "my_app"

  # override default decimal precision (5)
  # affects stat averages and task completion rate
  config.decimal_precision = 2

  # registers a custom resolution
  config.register_resolution :second, SecondResolution

  # unregisters any resolution
  config.unregister_resolutions(:minute, :hour)

  # sets TTL for redis keys of specific resolutions
  config.set_expirations({ minute: 1.hour, hour: 1.day })

end
```

#### Prefixing

Many applications use a single Redis instance for a number of uses:
background jobs, ephemeral data, TabsTabs , etc.  To avoid key collisions,
and to make it easier to drop all of your TabsTabs data without affecting
other parts of your system (or if more than one app shares the Redis
instance) you can prefix a given 'instance'.

Setting the prefix config option will cause all of the keys that TabsTabs
stores to use this format:

```
tabstabs:#{prefix}:#{key}..."
```

## Change Log & Breaking Changes

### v2.0.0

Fork of [Tabs](https://github.com/devmynd/tabs) due to its discontinuation
and incompatibility with newer Redis versions.

- Relaxed redis-rb version requirement
- Updated specs to new syntax

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Special Thanks

Thanks to [@DevMynd](https://github.com/devmynd) for creating the initial version
of this gem!