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

#### Include the module in ActiveFedora models you'd like to be baggable

```ruby
  class TestClass < ActiveFedora::Base
    include Hybag::Baggable
  end
```

#### To convert an exported bag back to a model

**NOTE:** Right now for this to work there must be datastreams defined on the discovered model which match the
metadata datastream IDs as tag files and content datastream IDs as data files. This means for a descMetadata
datastream to be populated bag_root/descMetadata.* (where * is the extension) must exist.

```ruby
  result = Hybag.ingest(BagIt::Bag.new("/path/to/bag"))
  result.class # => Model in fedora/rels-ext.rdf (preferred) or hybag.yml in bag root. More info below.
  result.persisted? # => false
```

## Configuration

#### Determining the model name.

Currently the model name is determined from the bag's fedora/rels-ext.rdf file (which Hybag::Baggable exports)
or a config file stored in bag_root/hybag.yml. The fedora rels-ext takes precedence. An example Hybag.yml format is
below

```yml
model: TestModel
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
