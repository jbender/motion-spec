# -*- encoding : utf-8 -*-
describe 'MotionSpec::Mock' do
  # Test class for mocking.
  class Dog
    def self.create
      new
    end

    def self.kind
      'Mammal'
    end

    def bark
      'Woof!'
    end

    def eat(food)
      "#{food}! Yum!"
    end

    # Calls the given block on the nearest toy, a stuffed mouse.
    def get_toy(&block)
      block.call('stuffed mouse')
    end

    # Calls the given block on true (for a succesful fetch) and 2 (the time it
    # took to fetch.
    def fetch(&block)
      block.call(true, 20)
    end
  end

  before { @dog = Dog.new }

  describe '#stub!' do
    it 'should stub a class method' do
      Dog.stub!(:thing, return: :thing)
      Dog.should.not.be.nil
      Dog.thing.should.eq :thing
    end

    it 'should stub an instance method' do
      my_obj = Object.new
      my_obj.stub!(:hello, return: 'hi')
      my_obj.hello.should.be.eq 'hi'
    end

    it 'should stub using block' do
      my_obj = Object.new
      my_obj.stub!(:hello) do |a, b|
        a.should.eq 'foo'
        b.should.eq 'bar'
        "#{a},#{b}"
      end
      my_obj.hello('foo', 'bar').should.be.eq 'foo,bar'
    end
  end

  describe '#stub' do
    it 'should create a pure stub' do
      my_stub = stub(:thing, return: 'dude, a thing!')
      my_stub.thing.should.eq 'dude, a thing!'
    end

    it 'should create a stub using block' do
      my_stub = stub(:thing) do |a, b|
        a.should.eq 'a'
        b.should.eq 'thing!'
        "dude, #{a} #{b}"
      end
      my_stub.thing('a', 'thing!').should.eq 'dude, a thing!'
    end
  end

  describe '#mock!' do
    it 'should mock an instance method on an object' do
      @dog.mock!(:bark, return: 'Meow!')
      @dog.mock!(:eat, return: 'Yuck!')
      @dog.bark.should.eq 'Meow!'
      @dog.eat('broccoli').should.eq 'Yuck!'
    end

    it 'should mock using block' do
      @dog.mock!(:bark) do |a|
        a.should.eq 'Meow!'
        a
      end
      @dog.bark('Meow!').should.eq 'Meow!'
    end

    it 'should mock a class method' do
      Dog.mock!(:create, return: 'Dog')
      Dog.create.should.eq 'Dog'
    end

    it 'should be able to yield a single object' do
      @dog.mock!(:get_toy, yield: 'stuffed fox')
      @dog.get_toy do |toy|
        toy.should.be.eq 'stuffed fox'
      end
    end

    it 'should be able to yield multiple objects' do
      @dog.mock!(:fetch, yield: [false, 10])
      @dog.fetch do |success, time|
        success.should.be.eq success
        time.should.be.eq 10
      end
    end

    it 'should be able to yield the boolean value false' do
      @dog.mock!(:get_toy, yield: false)
      @dog.get_toy do |toy|
        toy.should.be.eq false
      end
    end
  end

  describe '#mock' do
    it 'should create pure mock' do
      my_mock = mock(:hello, return: 'hi')
      my_mock.hello.should.eq 'hi'
    end
  end

  describe '#should_not_call' do
    it 'should raise an error with an instance method' do
      @dog.should_not_call(:bark)
      should.raise(MotionSpec::Error) do
        @dog.bark
      end
    end

    it 'should succeed if the call is not made' do
      should.not.raise(MotionSpec::Error) do
        @dog.should_not_call(:bark)
      end
    end

    it 'should not fail in another test' do
      should.not.raise(MotionSpec::Error) do
        @dog.bark
      end
    end

    it 'should raise an error with a class method' do
      Dog.should_not_call(:create)
      should.raise(MotionSpec::Error) do
        Dog.create
      end
    end
  end

  describe '#reset' do
    describe 'stubbing' do
      it 'should restore original class method' do
        Dog.stub!(:kind, return: 'Reptile')
        Dog.kind.should.eq 'Reptile'
        Dog.reset(:kind)
        Dog.kind.should.eq 'Mammal'
      end

      it 'should restore original instance method' do
        @dog.stub!(:bark, return: 'Meow!')
        @dog.bark.should.eq 'Meow!'
        @dog.reset(:bark)
        @dog.bark.should.eq 'Woof!'
      end
    end

    describe 'mocking' do
      it 'should restore original class method' do
        Dog.mock!(:kind, return: 'Reptile')
        Dog.kind.should.eq 'Reptile'
        Dog.reset(:kind)
        Dog.kind.should.eq 'Mammal'
      end

      it 'should restore original instance method' do
        @dog.mock!(:bark, return: 'Meow!')
        @dog.bark.should.eq 'Meow!'
        @dog.reset(:bark)
        @dog.bark.should.eq 'Woof!'
      end
    end
  end

  describe 'after each scenario' do
    it 'should verify mocks' do
      MotionSpec::Should.class_eval do
        def ignored_flunk(_message)
        end

        alias_method :original_flunk, :flunk
        alias_method :flunk, :ignored_flunk
      end

      Dog.mock!(:kind, return: 'Reptile')
      1.should.eq 1
    end

    it 'should have cleared mocks from the previous scenario' do
      1.should.eq 1

      MotionSpec::Should.class_eval { alias_method :flunk, :original_flunk }
    end

    describe 'clear stubs' do
      context 'with stub' do
        before { Dog.stub!(:kind, return: 'Foo') }

        it { Dog.kind.should.eq 'Foo' }
      end

      context 'without stub' do
        it { Dog.kind.should.eq 'Mammal' }
      end
    end
  end
end
