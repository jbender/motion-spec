# -*- encoding : utf-8 -*-

describe 'MotionSpec' do
  def succeed
    proc do |block|
      block.should.not.raise MotionSpec::Error
      true
    end
  end

  def fail
    proc do |block|
      block.should.raise MotionSpec::Error
      true
    end
  end

  def equal_string(x)
    proc { |s| x == s.to_s }
  end

  it 'has should.satisfy' do
    proc { should.satisfy { 1 == 1 } }.should succeed
    proc { should.satisfy { 1 } }.should succeed

    proc { should.satisfy { 1 != 1 } }.should fail
    proc { should.satisfy { false } }.should fail

    proc { 1.should.satisfy { |n| n % 2 == 0 } }.should fail
    proc { 2.should.satisfy { |n| n % 2 == 0 } }.should succeed
  end

  it 'has should.equal' do
    proc { 'string1'.should.eq 'string1' }.should succeed
    proc { 'string1'.should.eq 'string2' }.should fail
    proc { '1'.should.eq 1 }.should fail

    proc { 'string1'.should.equal 'string1' }.should succeed
    proc { 'string1'.should.equal 'string2' }.should fail
    proc { '1'.should.equal 1 }.should fail
  end

  it 'has should.raise' do
    proc { proc { raise 'Error' }.should.raise }.should succeed
    proc { proc { raise 'Error' }.should.raise RuntimeError }.should succeed
    proc { proc { raise 'Error' }.should.not.raise }.should fail
    proc { proc { raise 'Error' }.should.not.raise(RuntimeError) }.should fail

    proc { proc { 1 + 1 }.should.raise }.should fail
    proc { proc { raise 'Error' }.should.raise(Interrupt) }.should.raise
  end

  it 'has should.raise with a block' do
    proc { should.raise { raise 'Error' } }.should succeed
    proc { should.raise(RuntimeError) { raise 'Error' } }.should succeed
    proc { should.not.raise { raise 'Error' } }.should fail
    proc { should.not.raise(RuntimeError) { raise 'Error' } }.should fail

    proc { should.raise { 1 + 1 } }.should fail
    proc { should.raise(Interrupt) { raise 'Error' } }.should.raise
  end

  it 'has a should.raise should return the exception' do
    ex = proc { raise 'foo!' }.should.raise
    ex.should.be.kind_of RuntimeError
    ex.message.should =~ /foo/
  end

  it 'has should.be.an.instance_of' do
    proc { 'string'.should.be.instance_of String }.should succeed
    proc { 'string'.should.be.instance_of Hash }.should fail

    proc { 'string'.should.be.an.instance_of String }.should succeed
    proc { 'string'.should.be.an.instance_of Hash }.should fail
  end

  it 'has should.be.nil' do
    proc { nil.should.be.nil }.should succeed
    proc { nil.should.not.be.nil }.should fail
    proc { 'foo'.should.be.nil }.should fail
    proc { 'foo'.should.not.be.nil }.should succeed
  end

  it 'has should.include' do
    proc { [1, 2, 3].should.include 2 }.should succeed
    proc { [1, 2, 3].should.include 4 }.should fail

    proc { { 1 => 2, 3 => 4 }.should.include 1 }.should succeed
    proc { { 1 => 2, 3 => 4 }.should.include 2 }.should fail
  end

  it 'has should.be.a.kind_of' do
    proc { Array.should.be.kind_of Module }.should succeed
    proc { 'string'.should.be.kind_of Object }.should succeed
    proc { 1.should.be.kind_of Comparable }.should succeed

    proc { Array.should.be.a.kind_of Module }.should succeed

    proc { 'string'.should.be.a.kind_of Class }.should fail
  end

  it 'has should.match' do
    proc { 'string'.should.match(/strin./) }.should succeed
    proc { 'string'.should =~ /strin./ }.should succeed

    proc { 'string'.should.match(/slin./) }.should fail
    proc { 'string'.should =~ /slin./ }.should fail
  end

  it 'has should.not.raise' do
    proc { proc { 1 + 1 }.should.not.raise }.should succeed
    proc { proc { 1 + 1 }.should.not.raise(Interrupt) }.should succeed

    proc {
      proc {
        proc {
          Kernel.raise ZeroDivisionError.new('ArgumentError')
        }.should.not.raise(RuntimeError, Comparable)
      }.should.raise ZeroDivisionError
    }.should succeed

    proc { proc { raise 'Error' }.should.not.raise }.should fail
  end

  it 'has should.throw' do
    proc { proc { throw :foo }.should.throw(:foo) }.should succeed
    proc { proc {       :foo }.should.throw(:foo) }.should fail

    should.throw(:foo) { throw :foo }
  end

  it 'has should.not.satisfy' do
    proc { should.not.satisfy { 1 == 2 } }.should succeed
    proc { should.not.satisfy { 1 == 1 } }.should fail
  end

  it 'has should.not.equal' do
    proc { 'string1'.should.not.eq 'string2' }.should succeed
    proc { 'string1'.should.not.eq 'string1' }.should fail
  end

  it 'has should.not.match' do
    proc { 'string'.should.not.match(/sling/) }.should succeed
    proc { 'string'.should.not.match(/string/) }.should fail
    # proc { "string".should.not.match("strin") }.should fail

    proc { 'string'.should.not =~ /sling/ }.should succeed
    proc { 'string'.should.not =~ /string/ }.should fail
    # proc { "string".should.not =~ "strin" }.should fail
  end

  it 'has should.be.identical_to/same_as' do
    proc { s = 'string'; s.should.be.identical_to s }.should succeed
    proc { 'string'.should.be.identical_to 'string' }.should fail

    proc { s = 'string'; s.should.be.same_as s }.should succeed
    proc { 'string'.should.be.same_as 'string' }.should fail
  end

  it 'has should.respond_to' do
    proc { 'foo'.should.respond_to :to_s }.should succeed
    proc { 5.should.respond_to :to_str }.should fail
    proc { :foo.should.respond_to :nx }.should fail
  end

  it 'has should.be.close' do
    proc { 1.4.should.be.close 1.4, 0 }.should succeed
    # TODO this one is disabled because it will probably never run on MacRuby.
    # proc { 0.4.should.be.close 0.5, 0.1 }.should succeed

    proc { 0.4.should.be.close 0.5, 0.05 }.should fail
    proc { 0.4.should.be.close Object.new, 0.1 }.should fail
    proc { 0.4.should.be.close 0.5, -0.1 }.should fail
  end

  it 'supports multiple negation' do
    proc { 1.should.equal 1 }.should succeed
    proc { 1.should.not.equal 1 }.should fail
    proc { 1.should.not.not.equal 1 }.should succeed
    proc { 1.should.not.not.not.equal 1 }.should fail

    proc { 1.should.equal 2 }.should fail
    proc { 1.should.not.equal 2 }.should succeed
    proc { 1.should.not.not.equal 2 }.should fail
    proc { 1.should.not.not.not.equal 2 }.should succeed
  end

  it 'has should.<predicate>' do
    proc { [].should.be.empty }.should succeed
    proc { [1, 2, 3].should.not.be.empty }.should succeed

    proc { [].should.not.be.empty }.should fail
    proc { [1, 2, 3].should.be.empty }.should fail

    proc { { 1 => 2, 3 => 4 }.should.has_key 1 }.should succeed
    proc { { 1 => 2, 3 => 4 }.should.not.has_key 2 }.should succeed

    proc { nil.should.bla }.should.raise(NoMethodError)
    proc { nil.should.not.bla }.should.raise(NoMethodError)
  end

  it 'has should <operator> (>, >=, <, <=, ===)' do
    proc { 2.should.be > 1 }.should succeed
    proc { 1.should.be > 2 }.should fail

    proc { 1.should.be < 2 }.should succeed
    proc { 2.should.be < 1 }.should fail

    proc { 2.should.be >= 1 }.should succeed
    proc { 2.should.be >= 2 }.should succeed
    proc { 2.should.be >= 2.1 }.should fail

    proc { 2.should.be <= 1 }.should fail
    proc { 2.should.be <= 2 }.should succeed
    proc { 2.should.be <= 2.1 }.should succeed

    proc { Array.should.eq = [1, 2, 3] }.should succeed
    proc { Integer.should.eq = [1, 2, 3] }.should fail

    proc { /foo/.should.eq = 'foobar' }.should succeed
    proc { 'foobar'.should.eq = /foo/ }.should fail
  end

  it 'should allow for custom shoulds' do
    proc { (1 + 1).should equal_string('2') }.should succeed
    proc { (1 + 2).should equal_string('2') }.should fail

    proc { (1 + 1).should.be equal_string('2') }.should succeed
    proc { (1 + 2).should.be equal_string('2') }.should fail

    proc { (1 + 1).should.not equal_string('2') }.should fail
    proc { (1 + 2).should.not equal_string('2') }.should succeed
    proc { (1 + 2).should.not.not equal_string('2') }.should fail

    proc { (1 + 1).should.not.be equal_string('2') }.should fail
    proc { (1 + 2).should.not.be equal_string('2') }.should succeed
  end

  it 'has should.flunk' do
    proc { should.flunk }.should fail
    proc { should.flunk 'yikes' }.should fail
  end
end

describe 'before/after' do
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

  it 'runs in the right order' do
    @a.should.equal 2
    @b.should.equal 2
  end

  describe 'when nested' do
    before do
      @c = 5
    end

    it 'runs from higher level' do
      @a.should.equal 2
      @b.should.equal 2
    end

    it 'runs at the nested level' do
      @c.should.equal 5
    end

    before do
      @a = 5
    end

    it 'runs in the right order' do
      @a.should.equal 5
      @a = 2
    end
  end

  it 'does not run from lower level' do
    @c.should.be.nil
  end

  describe 'when nested at a sibling level' do
    it 'does not run from sibling level' do
      @c.should.be.nil
    end
  end
end

shared 'a shared context' do
  it 'gets called where it is included' do
    true.should.be.true
  end
end

shared 'another shared context' do
  it 'can access data' do
    @magic.should.be.equal 42
  end
end

describe 'shared/behaves_like' do
  behaves_like 'a shared context'

  ctx = self
  it 'raises NameError when the context is not found' do
    proc { ctx.behaves_like 'whoops' }.should.raise NameError
  end

  behaves_like 'a shared context'

  before {
    @magic = 42
  }
  behaves_like 'another shared context'
end

describe 'Methods' do
  def the_meaning_of_life
    42
  end

  it 'is accessible in a test' do
    the_meaning_of_life.should.eq 42
  end

  describe 'when in a sibling context' do
    it 'is accessible in a test' do
      the_meaning_of_life.should.eq 42
    end
  end
end

describe 'describe arguments' do
  # These specs are testing describe and each time describe gets called a new
  # context is popped onto the stack. This leads to some seemingly random
  # empty output at the end of the specs so let's just pop any newly added
  # contexts off that stack.
  before { @before_context_count = MotionSpec.instance_variable_get('@contexts').count }
  after do
    @contexts = MotionSpec.instance_variable_get('@contexts')
    (@contexts.count - @before_context_count).times { @contexts.pop }
  end

  def check(ctx, name)
    ctx.class.ancestors.should.include MotionSpec::Context
    ctx.instance_variable_get('@name').should.eq name
  end

  it 'works with string' do
    check(Kernel.send(:describe, 'string') {}, 'string')
  end

  it 'works with symbols' do
    check(Kernel.send(:describe, :behavior) {}, 'behavior')
  end

  it 'works with modules' do
    check(Kernel.send(:describe, MotionSpec) {}, 'MotionSpec')
  end

  it 'works with namespaced modules' do
    check(Kernel.send(:describe, MotionSpec::Context) {}, 'MotionSpec::Context')
  end

  it 'works with multiple arguments' do
    check(Kernel.send(:describe, MotionSpec::Context, :empty) {}, 'MotionSpec::Context empty')
  end

  it 'prefixes the name of a nested context with that of the parent context' do
    check(describe('are nested') {}, 'describe arguments are nested')
  end
end
