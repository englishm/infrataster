# Infrataster

[![Gem Version](https://badge.fury.io/rb/infrataster.png)](http://badge.fury.io/rb/infrataster)

Infrastructure Behavior Testing Framework.

## Basic Usage with Vagrant

First, create `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'infrataster'
```

Install gems:

```
$ bundle install
```

Install Vagrant: [Official Docs](http://docs.vagrantup.com/v2/installation/index.html)

Create Vagrantfile:

```ruby
# Vagrantfile
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"

  config.vm.define :proxy do |c|
    c.vm.network "private_network", ip: "192.168.33.10"
    c.vm.network "private_network", ip: "171.16.33.10", virtualbox__intnet: "infrataster-example"
  end

  config.vm.define :app do |c|
    c.vm.network "private_network", ip: "171.16.33.11", virtualbox__intnet: "infrataster-example"
  end
end
```

Start VMs:

```
$ vagrant up
```

Initialize rspec directory:

```
$ rspec --init
  create   spec/spec_helper.rb
  create   .rspec
```

`require 'infrataster/rspec'` and define target servers for testing in `spec/spec_helper.rb`:

```ruby
# spec/spec_helper.rb
require 'infrataster/rspec'

Infrataster::Server.define(
  :proxy,          # name
  '192.168.33.10', # ip address
  vagrant: true    # for vagrant VM
)
Infrataster::Server.define(
  :app,            # name
  '172.16.33.11',  # ip address
  vagrant: true,   # for vagrant VM
  from: :proxy     # access to this machine via SSH port forwarding from proxy
)

# Code generated by `rspec --init` is following...
```

Then, you can write spec files:

```ruby
# spec/example_spec.rb
require 'spec_helper'

describe server(:app) do
  describe http('http://app') do
    it "responds content including 'Hello Sinatra'" do
      expect(response.body).to include('Hello Sinatra')
    end
    it "responds as 'text/html'" do
      expect(response.header.content_type).to eq('text/html')
    end
  end
end
```

Run tests:

```
$ bundle exec rspec
2 examples, 2 failures
```

Currently, the tests failed because the VM doesn't respond to HTTP request.

It's time to write provisioning instruction like Chef's cookbooks or Puppet's manifests!

## Server

"Server" is a server you tests. This supports Vagrant, which is very useful to run servers for testing. Of course, you can test real servers.

You should define servers in `spec_helper.rb` like the following:

```ruby
Infrataster::Server.define(
  # Name of the server, this will be used in the spec files.
  :proxy,
  # IP address of the server
  '192.168.44.10',
  # If the server is provided by vagrant and this option is true,
  # SSH configuration to connect to this server is got from `vagrant ssh-config` command automatically.
  vagrant: true,
)

Infrataster::Server.define(
  # Name of the server, this will be used in the spec files.
  :app,
  # IP address of the server
  '172.16.44.11',
  # If the server is provided by vagrant and this option is true,
  # SSH configuration to connect to this server is got from `vagrant ssh-config` command automatically.
  vagrant: true,
  # Which gateway is used to connect to this server by SSH port forwarding?
  from: :proxy,
  # options for resources
  mysql: {user: 'app', password: 'app'},
)
```

You can specify SSH configuration manually too:

```ruby
Infrataster::Server.define(
  # ...
  ssh: {host: 'hostname', user: 'testuser', keys: ['/path/to/id_rsa']}
)
```

## Resources

"Resource" is what you test by Infrataster. For instance, the following code describes `http` resource.

```ruby
describe server(:app) do
  describe http('http://example.com') do
    it "responds content including 'Hello Sinatra'" do
      expect(response.body).to include('Hello Sinatra')
    end
  end
end
```

### `http` resource

`http` resource tests HTTP response when sending HTTP request.
It accepts `method`, `params` and `header` as options.

```ruby
describe server(:app) do
  describe http(
    'http://app.example.com',
    method: :post,
    params: {'foo' => 'bar'},
    headers: {'USER' => 'VALUE'}
  ) do
    it "responds with content including 'app'" do
      expect(response.body).to include('app')

      # `response` is a instance of `Faraday::Response`
      # See: https://github.com/lostisland/faraday/blob/master/lib/faraday/response.rb
    end
  end
end
```

### `capybara` resource

`capybara` resource tests your web application by simulating real user's interaction.

```ruby
describe server(:app) do
  describe capybara('http://app.example.com') do
    it 'shows food list' do
      visit '/'
      click_link 'Foods'
      expect(page).to have_content 'Yummy Soup'
    end
  end
end
```

If you use `capybara`, you should download and extract [BrowserMob Proxy](http://bmp.lightbody.net/) and set `Infrataster::BrowsermobProxy.bin_path` to binary path in `spec/spec_helper.rb`:

```ruby
# spec/spec_helper.rb
Infrataster::BrowsermobProxy.bin_path = '/path/to/browsermob/bin/browsermob'
```

(BrowserMob Proxy is needed to manipulate Host HTTP header.)

### `mysql_query` resource

`mysql_query` resource tests responce for mysql query.

```ruby
describe server(:db) do
  describe mysql_query('SHOW STATUS') do
    it 'returns positive uptime' do
      row = results.find {|r| r['Variable_name'] == 'Uptime' }
      expect(row['Value'].to_i).to be > 0

      # `results` is a instance of `Mysql2::Result`
      # See: https://github.com/brianmario/mysql2
    end
  end
end
```

You can specify username and password by options passed to `Infrataster::Server.define`:

```ruby
Infrataster::Server.define(
  # ...
  mysql: {user: 'app', password: 'app'}
)
```

## Example

* [example](example)
* [spec/integration](spec/integration)

## Tests

### Unit Tests

Unit tests are under `spec/unit` directory.

```
$ bundle exec rake spec:unit
```

### Integration Tests

Integration tests are under `spec/integration` directory.

```
$ bundle exec rake spec:integration:prepare
$ bundle exec rake spec:integration
```

## Presentations

* https://speakerdeck.com/ryotarai/infrataster-infra-behavior-testing-framework-number-oedo04

## Changelog

[Changelog](CHANGELOG.md)

## Contributing

1. Fork it ( http://github.com/ryotarai/infrataster/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
