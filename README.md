# MotionSpec
[![App Version](https://img.shields.io/gem/v/motion-spec.svg)](https://rubygems.org/gems/motion-spec)
[![Build Status](https://img.shields.io/travis/jbender/motion-spec/master.svg)](https://travis-ci.org/jbender/motion-spec)
[![Code Climate](https://img.shields.io/codeclimate/github/jbender/motion-spec.svg)](https://codeclimate.com/github/jbender/motion-spec)
[![Dependency Status](https://img.shields.io/gemnasium/jbender/motion-spec.svg)](https://gemnasium.com/jbender/motion-spec)
[![MIT Licensed](https://img.shields.io/github/license/jbender/motion-spec.svg)](https://github.com/jbender/motion-spec/blob/master/LICENSE)

Specs are important! This project makes them a first-class citizen again.

RubyMotion is great at integrating them from the start, but
they aren't core to the RubyMotion workflow, and lag behind their distant
`rspec` cousin (RubyMotion's specs are forked from `MacBacon`, which is a port
of `Bacon` which is a simplified version of `rspec`).

## Installation

Add this line to your app's `Gemfile`:

```ruby
gem 'motion-spec'
```

If your `Rakefile` includes this line you're all set:

```ruby
Bundler.require
```

Otherwise, you'll need to add this line to the top of your `Rakefile`:

```ruby
require 'motion-spec'
```

## Usage

### By Example

```ruby
describe AwesomeClass do
  it 'initializes with defaults' do
    expect(AwesomeClass.new.attribute).to eq 'my default'
  end

  it { expect(true).to be_true }

  context 'with a precondition' do
    before { AwesomeClass.build_context }
    after { AwesomeClass.reset_all }

    let(:example_1) { AwesomeClass.new(foo: 'bar') }
    subject { example_1.instance_function }

    it { is_expected.to have_foo('bar') }
  end

  context 'stubbing a method' do
    before { subject.stub!(:awesome_method, return: 'awesomeness') }

    subject { AwesomeClass.new }

    it { expect(subject.awesome_method).to eq 'awesomeness' }
  end
end
```

### `mock!` vs `stub!`

`mock!` ensures that the method is called (and removes the implementation when
it is), while `stub!` simply replaces the method for the duration of the spec.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jbender/motion-spec.
