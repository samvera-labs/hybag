# Hybag

A Hydra gem for adding BagIt functionality to ActiveFedora models.

## Installation

Add this line to your application's Gemfile:

    gem 'hybag'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hybag

## Usage

### Include the module in ActiveFedora models you'd like to be baggable

```ruby
  class TestClass < ActiveFedora::Base
    include Hybag::Baggable
  end
```

### Examples

#### Write the item to disk in rails_root/tmp/bags/filler/pid
```ruby
  test_class = TestClass.new.write_bag('filler')
```

#### Delete a bag that was written already
```ruby
  test_class.delete_bag
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
