$-w,w = nil, $-w
require File.expand_path('../spec_helper', __FILE__)
$-w = w

# Hooray for meta-testing.
module MetaTests
  def succeed
    lambda { |block|
      block.should.not.raise Bacon::Error
      true
    }
  end

  def fail
    lambda { |block|
      block.should.raise Bacon::Error
      true
    }
  end

  def equal_string(x)
    lambda { |s|
      x == s.to_s
    }
  end
end

describe "Bacon" do
  include MetaTests
  
  it "should have should.satisfy" do
    lambda { should.satisfy { 1 == 1 } }.should succeed
    lambda { should.satisfy { 1 } }.should succeed

    lambda { should.satisfy { 1 != 1 } }.should fail
    lambda { should.satisfy { false } }.should fail
    lambda { should.satisfy { false } }.should fail

    lambda { 1.should.satisfy { |n| n % 2 == 0 } }.should fail
    lambda { 2.should.satisfy { |n| n % 2 == 0 } }.should succeed
  end

  it "should have should.equal" do
    lambda { "string1".should == "string1" }.should succeed
    lambda { "string1".should == "string2" }.should fail
    lambda { "1".should == 1 }.should fail

    lambda { "string1".should.equal "string1" }.should succeed
    lambda { "string1".should.equal "string2" }.should fail
    lambda { "1".should.equal 1 }.should fail
  end

  it "should have should.raise" do
    lambda { lambda { raise "Error" }.should.raise }.should succeed
    lambda { lambda { raise "Error" }.should.raise RuntimeError }.should succeed
    lambda { lambda { raise "Error" }.should.not.raise }.should fail
    lambda { lambda { raise "Error" }.should.not.raise(RuntimeError) }.should fail

    lambda { lambda { 1 + 1 }.should.raise }.should fail
    lambda {
      lambda { raise "Error" }.should.raise(Interrupt)
    }.should.raise
  end

  it "should have should.raise with a block" do
    lambda { should.raise { raise "Error" } }.should succeed
    lambda { should.raise(RuntimeError) { raise "Error" } }.should succeed
    lambda { should.not.raise { raise "Error" } }.should fail
    lambda { should.not.raise(RuntimeError) { raise "Error" } }.should fail

    lambda { should.raise { 1 + 1 } }.should fail
    lambda {
      should.raise(Interrupt) { raise "Error" }
    }.should.raise
  end

  it "should have a should.raise should return the exception" do
    ex = lambda { raise "foo!" }.should.raise
    ex.should.be.kind_of RuntimeError
    ex.message.should =~ /foo/
  end
  
  it "should have should.be.an.instance_of" do
    lambda { "string".should.be.instance_of String }.should succeed
    lambda { "string".should.be.instance_of Hash }.should fail

    lambda { "string".should.be.an.instance_of String }.should succeed
    lambda { "string".should.be.an.instance_of Hash }.should fail
  end

  it "should have should.be.nil" do
    lambda { nil.should.be.nil }.should succeed
    lambda { nil.should.not.be.nil }.should fail
    lambda { "foo".should.be.nil }.should fail
    lambda { "foo".should.not.be.nil }.should succeed
  end

  it "should have should.include" do
    lambda { [1,2,3].should.include 2 }.should succeed
    lambda { [1,2,3].should.include 4 }.should fail

    lambda { {1=>2, 3=>4}.should.include 1 }.should succeed
    lambda { {1=>2, 3=>4}.should.include 2 }.should fail
  end

  it "should have should.be.a.kind_of" do
    lambda { Array.should.be.kind_of Module }.should succeed
    lambda { "string".should.be.kind_of Object }.should succeed
    lambda { 1.should.be.kind_of Comparable }.should succeed

    lambda { Array.should.be.a.kind_of Module }.should succeed

    lambda { "string".should.be.a.kind_of Class }.should fail
  end

  it "should have should.match" do
    lambda { "string".should.match(/strin./) }.should succeed
    lambda { "string".should =~ /strin./ }.should succeed

    lambda { "string".should.match(/slin./) }.should fail
    lambda { "string".should =~ /slin./ }.should fail
  end

  it "should have should.not.raise" do
    lambda { lambda { 1 + 1 }.should.not.raise }.should succeed
    lambda { lambda { 1 + 1 }.should.not.raise(Interrupt) }.should succeed

    lambda {
      lambda {
        lambda {
          Kernel.raise ZeroDivisionError.new("ArgumentError")
        }.should.not.raise(RuntimeError, Comparable)
      }.should.raise ZeroDivisionError
    }.should succeed
      
    lambda { lambda { raise "Error" }.should.not.raise }.should fail
  end

  it "should have should.throw" do
    lambda { lambda { throw :foo }.should.throw(:foo) }.should succeed
    lambda { lambda {       :foo }.should.throw(:foo) }.should fail

    should.throw(:foo) { throw :foo }
  end

  it "should have should.not.satisfy" do
    lambda { should.not.satisfy { 1 == 2 } }.should succeed
    lambda { should.not.satisfy { 1 == 1 } }.should fail
  end

  it "should have should.not.equal" do
    lambda { "string1".should.not == "string2" }.should succeed
    lambda { "string1".should.not == "string1" }.should fail
  end

  it "should have should.not.match" do
    lambda { "string".should.not.match(/sling/) }.should succeed
    lambda { "string".should.not.match(/string/) }.should fail
#    lambda { "string".should.not.match("strin") }.should fail

    lambda { "string".should.not =~ /sling/ }.should succeed
    lambda { "string".should.not =~ /string/ }.should fail
#    lambda { "string".should.not =~ "strin" }.should fail
  end

  it "should have should.be.identical_to/same_as" do
    lambda { s = "string"; s.should.be.identical_to s }.should succeed
    lambda { "string".should.be.identical_to "string" }.should fail

    lambda { s = "string"; s.should.be.same_as s }.should succeed
    lambda { "string".should.be.same_as "string" }.should fail
  end

  it "should have should.respond_to" do
    lambda { "foo".should.respond_to :to_s }.should succeed
    lambda { 5.should.respond_to :to_str }.should fail
    lambda { :foo.should.respond_to :nx }.should fail
  end
  
  it "should have should.be.close" do
    lambda { 1.4.should.be.close 1.4, 0 }.should succeed
    # TODO this one is disabled because it will probably never run on MacRuby.
    #lambda { 0.4.should.be.close 0.5, 0.1 }.should succeed

    lambda { 0.4.should.be.close 0.5, 0.05 }.should fail
    lambda { 0.4.should.be.close Object.new, 0.1 }.should fail
    lambda { 0.4.should.be.close 0.5, -0.1 }.should fail
  end

  it "should support multiple negation" do
    lambda { 1.should.equal 1 }.should succeed
    lambda { 1.should.not.equal 1 }.should fail
    lambda { 1.should.not.not.equal 1 }.should succeed
    lambda { 1.should.not.not.not.equal 1 }.should fail

    lambda { 1.should.equal 2 }.should fail
    lambda { 1.should.not.equal 2 }.should succeed
    lambda { 1.should.not.not.equal 2 }.should fail
    lambda { 1.should.not.not.not.equal 2 }.should succeed
  end

  it "should have should.<predicate>" do
    lambda { [].should.be.empty }.should succeed
    lambda { [1,2,3].should.not.be.empty }.should succeed

    lambda { [].should.not.be.empty }.should fail
    lambda { [1,2,3].should.be.empty }.should fail

    lambda { {1=>2, 3=>4}.should.has_key 1 }.should succeed
    lambda { {1=>2, 3=>4}.should.not.has_key 2 }.should succeed

    lambda { nil.should.bla }.should.raise(NoMethodError)
    lambda { nil.should.not.bla }.should.raise(NoMethodError)
  end

  it "should have should <operator> (>, >=, <, <=, ===)" do
    lambda { 2.should.be > 1 }.should succeed
    lambda { 1.should.be > 2 }.should fail

    lambda { 1.should.be < 2 }.should succeed
    lambda { 2.should.be < 1 }.should fail

    lambda { 2.should.be >= 1 }.should succeed
    lambda { 2.should.be >= 2 }.should succeed
    lambda { 2.should.be >= 2.1 }.should fail

    lambda { 2.should.be <= 1 }.should fail
    lambda { 2.should.be <= 2 }.should succeed
    lambda { 2.should.be <= 2.1 }.should succeed

    lambda { Array.should === [1,2,3] }.should succeed
    lambda { Integer.should === [1,2,3] }.should fail

    lambda { /foo/.should === "foobar" }.should succeed
    lambda { "foobar".should === /foo/ }.should fail
  end

  it "should allow for custom shoulds" do
    lambda { (1+1).should equal_string("2") }.should succeed
    lambda { (1+2).should equal_string("2") }.should fail

    lambda { (1+1).should.be equal_string("2") }.should succeed
    lambda { (1+2).should.be equal_string("2") }.should fail

    lambda { (1+1).should.not equal_string("2") }.should fail
    lambda { (1+2).should.not equal_string("2") }.should succeed
    lambda { (1+2).should.not.not equal_string("2") }.should fail

    lambda { (1+1).should.not.be equal_string("2") }.should fail
    lambda { (1+2).should.not.be equal_string("2") }.should succeed
  end

  it "should have should.flunk" do
    lambda { should.flunk }.should fail
    lambda { should.flunk "yikes" }.should fail
  end
end

describe "before/after" do
  before do
    @a = 1
    @b = 2
  end

  before do
    @a = 2
  end

  after do
    @a.should.equal 2
    @a = 3
  end

  after do
    @a.should.equal 3
  end
  
  it "should run in the right order" do
    @a.should.equal 2
    @b.should.equal 2
  end
  
  describe "when nested" do
    before do
      @c = 5
    end
    
    it "should run from higher level" do
      @a.should.equal 2
      @b.should.equal 2
    end
    
    it "should run at the nested level" do
      @c.should.equal 5
    end
    
    before do
      @a = 5
    end
    
    it "should run in the right order" do
      @a.should.equal 5
      @a = 2
    end
  end
  
  it "should not run from lower level" do
    @c.should.be.nil
  end
  
  describe "when nested at a sibling level" do
    it "should not run from sibling level" do
      @c.should.be.nil
    end
  end
end

shared "a shared context" do
  it "gets called where it is included" do
    true.should.be.true
  end
end

shared "another shared context" do
  it "can access data" do
    @magic.should.be.equal 42
  end
end

describe "shared/behaves_like" do
  behaves_like "a shared context"

  ctx = self
  it "raises NameError when the context is not found" do
    lambda {
      ctx.behaves_like "whoops"
    }.should.raise NameError
  end

  behaves_like "a shared context"

  before {
    @magic = 42
  }
  behaves_like "another shared context"
end

describe "Methods" do
  def the_meaning_of_life
    42
  end

  it "should be accessible in a test" do
    the_meaning_of_life.should == 42
  end

  describe "when in a sibling context" do
    it "should be accessible in a test" do
      the_meaning_of_life.should == 42
    end
  end
end

describe 'describe arguments' do
  def check(ctx, name)
    ctx.ancestors.should.include Bacon::Context
    ctx.instance_variable_get('@name').should == name
  end

  it 'should work with string' do
    check(Kernel.send(:describe, 'string') {}, 'string')
  end

  it 'should work with symbols' do
    check(Kernel.send(:describe, :behaviour) {}, 'behaviour')
  end

  it 'should work with modules' do
    check(Kernel.send(:describe, Bacon) {}, 'Bacon')
  end

  it 'should work with namespaced modules' do
    check(Kernel.send(:describe, Bacon::Context) {}, 'Bacon::Context')
  end

  it 'should work with multiple arguments' do
    check(Kernel.send(:describe, Bacon::Context, :empty) {}, 'Bacon::Context empty')
  end

  it "prefixes the name of a nested context with that of the parent context" do
    check(describe('are nested') {}, 'describe arguments are nested')
  end
end


# TODO move to MacBacon specific spec?
if Bacon.concurrent?
  describe "Concurrency" do
    it "returns that the specifications of the context should not be run on the main thread by default" do
      self.class.should.not.run_on_main_thread
    end

    describe ", concerning disabling per context, " do
      self.run_on_main_thread = true

      class << self
        attr_accessor :ran_specs
      end
      self.ran_specs = []

      after do
        self.class.ran_specs << self.specification
      end

      it "runs the specs sequentially (part 1)" do
        self.class.ran_specs.size.should == 0
      end

      it "forces the specifications to run on the main thread" do
        Dispatch::Queue.current.to_s.should == Dispatch::Queue.main.to_s
      end

      it "runs the specs sequentially (part 2)" do
        self.class.ran_specs.size.should == 2
      end
    end
  end
else
  puts "[!] Skipping the majority of the concurrency related specs, as Bacon is not running in concurrent mode. Enable it with the `-c' command-line option."
  describe "Concurrency" do
    it "returns that the specifications of the context should be run on the main thread by default" do
      self.class.should.run_on_main_thread
    end

    it "forces the specifications to run on the main thread" do
      Dispatch::Queue.current.to_s.should == Dispatch::Queue.main.to_s
    end
  end
end

describe "delegate callbacks" do
  def initialize(spec)
    super(spec)
    spec.delegate = self
  end

  def bacon_specification_will_start(spec)
    @started = spec
  end

  before do
    # The callback should have been called even before the `before' filter
    @started.should == @specification
  end

  it "notifies before a spec starts" do
    @started.should == @specification
  end

  it "notifies after a spec has finished" do
    # just to make the spec pass
    true.should == true

    def bacon_specification_did_finish(spec)
      @finished = spec
    end
    at_exit do
      unless @finished == @specification
        puts
        raise "Expected the delegate to be called after a spec hash finished, but it didn't."
      end
    end
  end

  it "notifies after all specs have run" do
    # just to make the spec pass
    true.should == true

    Bacon.delegate = self
    def bacon_did_finish
      @bacon_finished = true
    end
    at_exit do
      unless @bacon_finished
        puts
        raise "Expected the delegate to be called after all specs have finished, but it didn't."
      end
    end
  end
end
