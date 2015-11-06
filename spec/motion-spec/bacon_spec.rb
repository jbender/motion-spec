# -*- encoding : utf-8 -*-

describe 'MotionSpec' do
  describe 'before/after' do
    before do
      @a = 1
      @b = 2
    end

    before { @a = 2 }

    after do
      @a.should.equal 2
      @a = 3
    end

    after { @a.should.equal 3 }

    it 'runs in the right order' do
      @a.should.equal 2
      @b.should.equal 2
    end

    describe 'when nested' do
      before { @c = 5 }

      it 'runs from higher level' do
        @a.should.equal 2
        @b.should.equal 2
      end

      it 'runs at the nested level' do
        @c.should.equal 5
      end

      before { @a = 5 }

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

  describe 'it' do
    context 'with a description' do
      before do
        @example = proc { it('with a description') { true.should.be.true } }
      end

      it 'is valid' { @example.should.not.raise }
    end

    context 'without a description' do
      before do
        @example = proc { it { true.should.be.true } }
      end

      it 'is valid' { @example.should.not.raise }
    end
  end

  describe 'shared contexts' do
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

    shared 'shared behavior with before' do
      before { @shared_before = 'foo' }
    end

    describe 'it_behaves_like' do
      it_behaves_like 'a shared context'

      ctx = self
      it 'raises NameError when the context is not found' do
        proc { ctx.behaves_like 'whoops' }.should.raise NameError
      end

      it_behaves_like 'a shared context'

      before { @magic = 42 }
      it_behaves_like 'another shared context'

      context 'isolates instance variables' do
        it_behaves_like 'shared behavior with before' do
          it 'runs within context of shared block' do
            @shared_before.should.eq 'foo'
          end
        end

        it 'does not leak instance variables' do
          @shared_before.should.eq nil
        end
      end
    end

    describe 'include_examples' do
      include_examples 'a shared context'

      before { @magic = 42 }
      include_examples 'another shared context'

      context 'sets instance variables in parent scope' do
        include_examples 'shared behavior with before'

        it 'adds instance variables' do
          @shared_before.should.eq 'foo'
        end
      end
    end
  end

  describe 'methods' do
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
      check(describe('are nested') {}, 'MotionSpec describe arguments are nested')
    end
  end
end
