# Yodeler

A generic instrumentation library thats supports reporting to multiple endpoints via pluggable backend adapters.

Spoutin' off noise to whoever is listening.

![Build Status](https://travis-ci.org/coryodaniel/yodeler.svg "Build Status")
[![Test Coverage](https://codeclimate.com/github/coryodaniel/yodeler/badges/coverage.svg)](https://codeclimate.com/github/coryodaniel/yodeler/coverage)
[![Code Climate](https://codeclimate.com/github/coryodaniel/yodeler/badges/gpa.svg)](https://codeclimate.com/github/coryodaniel/yodeler)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yodeler', '~>0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yodeler

## Usage

### Configuration
Create an initializer in ```config/initializers/yodeler.rb```
TODO

#### HTTP Adapter Example
TODO

#### HTTP Adapter [Dashing Example](https://github.com/stacksocial/dashing)
TODO

#### Propono (SNS/SQS) Example
TODO

### Collecting Metrics
TODO

### Emitting Events
TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coryodaniel/yodeler.

## TODOs
  * [ ] Pull DSL examples from yodeler_spec
    * [ ] A full configuration example
    * [ ] Instrumentation examples
  * [ ] yodeler-adapter-http (http.rb)
  * [ ] yodeler-adapter-propono
  * [ ] yodeler-adapter-statsd
  * [ ] Custom adapter documentation
