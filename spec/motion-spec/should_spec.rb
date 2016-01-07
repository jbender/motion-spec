# -*- encoding : utf-8 -*-

describe MotionSpec::Should do
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
    # rubocop:disable Lint/UselessComparison
    proc { should.satisfy { 1 == 1 } }.should succeed
    # rubocop:enable Lint/UselessComparison
    proc { should.satisfy { 1 } }.should succeed

    # rubocop:disable Lint/UselessComparison
    proc { should.satisfy { 1 != 1 } }.should fail
    # rubocop:enable Lint/UselessComparison
    proc { should.satisfy { false } }.should fail

    proc { 1.should.satisfy(&:even?) }.should fail
    proc { 2.should.satisfy(&:even?) }.should succeed
  end

  it 'has should.equal' do
    proc { 'string1'.should.eq 'string1' }.should succeed
    proc { 'string1'.should.eq 'string2' }.should fail
    proc { '1'.should.eq 1 }.should fail

    proc { 'string1'.should.equal 'string1' }.should succeed
    proc { 'string1'.should.equal 'string2' }.should fail
    proc { '1'.should.equal 1 }.should fail
  end

  # rubocop:disable Style/SignalException
  it 'has should.raise' do
    proc { proc { raise 'Error' }.should.raise }.should succeed
    proc { proc { raise 'Error' }.should.raise(RuntimeError) }.should succeed
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
  # rubocop:enable Style/SignalException

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

    proc do
      proc do
        proc do
          Kernel.fail ZeroDivisionError.new('ArgumentError')
        end.should.not.raise(RuntimeError, Comparable)
      end.should.raise ZeroDivisionError
    end.should succeed

    # rubocop:disable Style/SignalException
    proc { proc { raise 'Error' }.should.not.raise }.should fail
    # rubocop:enable Style/SignalException
  end

  it 'has should.throw' do
    proc { proc { throw :foo }.should.throw(:foo) }.should succeed
    proc { proc { :foo }.should.throw(:foo) }.should fail

    should.throw(:foo) { throw :foo }
  end

  # rubocop:disable Lint/UselessComparison
  it 'has should.not.satisfy' do
    proc { should.not.satisfy { 1 == 2 } }.should succeed
    proc { should.not.satisfy { 1 == 1 } }.should fail
  end
  # rubocop:enable Lint/UselessComparison

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
    proc do
      s = 'string'
      s.should.be.identical_to s
    end.should succeed
    proc { 'string'.should.be.identical_to 'string' }.should fail

    proc do
      s = 'string'
      s.should.be.same_as s
    end.should succeed
    proc { 'string'.should.be.same_as 'string' }.should fail
  end

  it 'has should.respond_to' do
    proc { 'foo'.should.respond_to :to_s }.should succeed
    proc { 5.should.respond_to :to_str }.should fail
    proc { :foo.should.respond_to :nx }.should fail
  end

  it 'has should.be.close' do
    proc { 1.4.should.be.close 1.4, 0 }.should succeed
    proc { 0.4.should.be.close 0.45, 0.1 }.should succeed

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

describe "#should shortcut for #it('should')" do
  should 'be called' do
    @called = true
    @called.should.eq true
  end

  # rubocop:disable Lint/UselessComparison
  should 'save some characters by typing should' do
    proc { should.satisfy { 1 == 1 } }.should.not.raise
  end

  should 'save characters even on failure' do
    proc { should.satisfy { 1 == 2 } }.should.raise MotionSpec::Error
  end

  should 'work nested' do
    should.satisfy { 1 == 1 }
  end
  # rubocop:enable Lint/UselessComparison

  # before { @count = MotionSpec::Counter[:specifications] }
  # should 'add new specifications' do
  #   (@count + 1).should.eq MotionSpec::Counter[:specifications]
  # end

  should 'have been called' do
    @called.should.eq true
  end
end
