# Yodeler

A generic instrumentation library thats supports reporting to multiple endpoints via pluggable backend adapters.

Spoutin' off noise to whoever is listening.

![Build Status](https://travis-ci.org/coryodaniel/yodeler.svg "Build Status")
[![Test Coverage](https://codeclimate.com/github/coryodaniel/yodeler/badges/coverage.svg)](https://codeclimate.com/github/coryodaniel/yodeler/coverage)
[![Code Climate](https://codeclimate.com/github/coryodaniel/yodeler/badges/gpa.svg)](https://codeclimate.com/github/coryodaniel/yodeler)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yodeler', '~>0.1.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yodeler

## Usage

### Configuration

#### Single endpoint
In ```config/initializers/yodeler.rb```
```ruby
Yodeler.configure do |client|
  # if no endpoint name is given, it defaults to :default
  client.adapter(:http) do |http|
    http.path = '/events'
    http.host = 'example.com'
    # http.port = 80
    # http.use_ssl = false
    # http.default_params = {}
  end
end
```

#### Multiple Endpoints
In ```config/initializers/yodeler.rb```
```ruby

Yodeler.configure do |client|
  client.endpoint(:sales_reporting).adapter(:http) do |http|
    http.path = '/events'
    http.host = 'sales.example.com'
  end

  client.endpoint(:devops_reporting).adapter(:http) do |http|
    http.path = '/events'
    http.host = 'devops.example.com'
  end

  # by default, the client dispatches to the first registered endpoint
  # you can change it to a different one
  # Alternatively you can dispatch to a set of endpoints when dispatching a metric
  #   Yodeler.gauge('users.count', 35, to: [:sales_reporting, :devops_reporting])
  client.default_endpoint_name = :devops_reporting
end
```

#### Full Configuration Example
In ```config/yodeler.yml```
```yaml
development:
  auth_token: SOSECUREZ
  sales_reporting:
    host: localhost
    port: 3030
  devops_reporting:
    host: localhost
    port: 3031    
```

In ```config/initializers/yodeler.rb```
```ruby
config = YAML.load(File.read("./config/yodeler.yml"))[Rails.env]

Yodeler.configure do |client|
  client.endpoint(:sales_reporting).adapter(:http) do |http|
    http.path = '/events'
    http.host = config[:sales_reporting][:host]
    http.port = config[:sales_reporting][:port]
    http.default_params = {
      auth_token: config[:auth_token]
    }
  end

  client.endpoint(:devops_reporting).adapter(:http) do |http|
    http.path = '/events'
    http.host = config[:devops_reporting][:host]
    http.port = config[:devops_reporting][:port]
    http.default_params = {
      auth_token: config[:auth_token]
    }

    # Overwrite the default http dispatcher or overwrite an individual metric dispatcher
    #   http.handle(:gauge){ |url, metric, default_params| ... something cool ... }
    http.handle(:default) do |url, metric, default_params|
      # This is the default handler definition, but you could change it
      HTTP.post(url, json: default_params.merge(metric.to_hash))
    end
  end

  client.default_endpoint_name = :devops_reporting
end

```

#### [Dashing Example](https://github.com/shopify/dashing)
```ruby
Yodeler.configure do |client|
  client.endpoint(:karma_widget).adapter(:http) do |http|
    http.path = '/widgets/karma'
    http.host = 'localhost'
    http.default_params = {
      auth_token: config[:auth_token]
    }
  end

  client.endpoint(:user_count_widget).adapter(:http) do |http|
    http.path = '/widgets/user_count'
    http.host = 'localhost'
    http.default_params = {
      auth_token: config[:auth_token]
    }
  end
end
```

### Publishing Metrics and Events

#### All instrumentation methods support an options hash

* :prefix - [~String] :prefix your metric/event names
* :tags   - [Array<String,Symbol>, String, Symbol] :tags ([]) array of tags to apply to metric/event
* :sample_rate - [Float] :sample_rate (1.0) The sample rate to use
* :to - [Array<Symbol>, Symbol] :to array of endpoint names to send the metric/event to. If not set will send to Yodeler::Client#default_endpoint_name

#### Gauge
```ruby
Yodeler.gauge 'user.count', 35
Yodeler.gauge 'user.count', 35, prefix: 'test'
Yodeler.gauge 'user.count', 35, sample_rate: 0.5
Yodeler.gauge 'user.count', 35, prefix: 'test', tags: ['cool']
Yodeler.gauge 'user.count', 35, to: [:devops_reporting, :sales_reporting]
```

#### Increment
```ruby
Yodeler.increment 'users.count'
Yodeler.increment 'users.count', to: [:devops_reporting, :sales_reporting]
Yodeler.increment 'revenue', 10_000
Yodeler.increment 'revenue', 10_000, to: [:devops_reporting, :sales_reporting]

```

#### Timing
```ruby
Yodeler.timing('eat.sandwich', {prefix: :test}) do
  user.eat(sandwich)
end #=> returns result of block

Yodeler.timing 'eat.sandwich', 250 #in ms
Yodeler.timing 'eat.sandwich', 250, to: [:devops_reporting, :sales_reporting]
```

#### Event
```ruby
wizz_bang = {name: 'Wizz Bang 3000', image_url: 'http://example.com/wizzbang.jpg'}
Yodeler.publish 'product.sold', wizz_bang
Yodeler.publish 'product.sold', wizz_bang, prefix: 'ecommerce'
Yodeler.publish 'product.sold', wizz_bang, sample_rate: 0.25
Yodeler.publish 'product.sold', wizz_bang, to: [:devops_reporting, :sales_reporting]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coryodaniel/yodeler.

## TODOs
  * [ ] Custom adapter documentation
  * [ ] Client#format_options -> Metric.format_options
  * [ ] Client#default_endpoint_name accept array of names
  * [ ] Dispatch to any object or proc, if adapter not registered
    -> client.endpoint(:dashboard).use(:something_that_responds_to_dispatch)
    -> client.endpoint(:dashboard).use{ |metric| MyWorker.perform_later(metric) }
  * [ ] more yard docs
