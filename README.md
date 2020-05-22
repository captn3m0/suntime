# suntime

Crystal library for calculating sunrise and sunset times. Uses the algorithm from <http://www.edwilliams.org/sunrise_sunset_algorithm.htm>.

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
Suntime.new(lat,long, time)
```

## Development

TODO: Write development instructions here

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
