# suntime

Crystal library for calculating sunrise and sunset times. Uses the algorithm from <https://www.esrl.noaa.gov/gmd/grad/solcalc/solareqns.PDF>

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     suntime:
       github: captn3m0/suntime
   ```

2. Run `shards install`

## Usage

```crystal
require "suntime"

# Time is optional, local time is used otherwise
# It returns sunrise/sunset for TODAY, so if you want the next sunset, check accordingly
s = Suntime::Suntime.new(lat,long, time)
# Bangalore
s = Suntime::Suntime.new(12.955800, 77.620979)
s.sunrise
# 2020-05-22 05:52:48.0 +05:30 Local
s.sunset
# 2020-05-22 18:39:43.0 +05:30 Local
```

You can pass in a different time. The date is used for calculating the sunrise/sunset, and the timezone is used for return formatting.

## TODO

- [ ] Implement the Atmospheric Refraction Effect calculation
- [ ] Uncomment true_solar_time after converting it to proper time object

## Contributing

1. Fork it (<https://github.com/captn3m0/suntime/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Nemo](https://github.com/captn3m0) - creator and maintainer

## License

Licensed under the [MIT License](https://nemo.mit-license.org/). See LICENSE file for details.
