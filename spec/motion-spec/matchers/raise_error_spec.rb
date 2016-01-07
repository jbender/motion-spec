# -*- encoding : utf-8 -*-
describe 'Matcher::RaiseError' do
  context 'without arguments' do
    it 'passes when the block raises any exception' do
      expect { 1 / 0 }.to raise_error
    end

    it "failes when the block doesn't raise any exception" do
      expect_failure('Block expected to raise error') do
        expect { Object.new }.to raise_error
      end
    end
  end

  context 'with a class argument' do
    it 'passes when the block raises an exception of the argument class' do
      expect { 1 / 0 }.to raise_error(ZeroDivisionError)
    end

    it 'fails when the block raises an exception of a different class' do
      expect_failure('Block expected to raise error of type ArgumentError') do
        expect { 1 / 0 }.to raise_error(ArgumentError)
      end
    end

    it 'fails when the block raises an exception of the argument class but asked not to' do
      expect_failure('Block not expected to raise error of type ZeroDivisionError') do
        expect { 1 / 0 }.not_to raise_error(ZeroDivisionError)
      end
    end
  end

  context 'with a string argument' do
    context 'raised message includes the string' do
      it 'passes' do
        expect { fail 'one message' }.to raise_error('one message')
      end
    end

    context 'raised message does not include the string' do
      it 'fails' do
        message =
          "Block expected to raise error with message matching \"different\" " \
          'but was #<RuntimeError: one message>'

        expect_failure(message) do
          expect { fail 'one message' }.to raise_error('different')
        end
      end
    end
  end

  context 'with a regex argument' do
    context 'raised message matches the regex' do
      it 'passes' do
        expect { fail 'one message' }.to raise_error(/message/)
      end
    end

    context 'raised message does not matches the regex' do
      it 'fails' do
        message =
          'Block expected to raise error with message matching ' \
          "#{/different/.inspect} but was #<RuntimeError: one message>"

        expect_failure(message) do
          expect { fail 'one message' }.to raise_error(/different/)
        end
      end
    end
  end

  context 'with a class and string arguments' do
    it 'passes if the block raises an exception of the same class and includes the string in its message' do
      expect { fail ArgumentError.new('with a message') }.to raise_error(ArgumentError, 'message')
    end

    it "fails if the block raises an exception of the same class and but doesn't include the string in its message" do
      message =
        'Block expected to raise error of type ArgumentError with message ' \
        "matching #{'different'.inspect}"

      expect_failure(message) do
        expect { fail ArgumentError.new('with a message') }.to raise_error(ArgumentError, 'different')
      end
    end

    it 'fails if the block raises an exception of a different class' do
      message =
        'Block expected to raise error of type ZeroDivisionError with message ' \
        "matching #{'message'.inspect}"

      expect_failure(message) do
        expect { fail ArgumentError.new('with a message') }.to raise_error(ZeroDivisionError, 'message')
      end
    end
  end

  context 'with a class and regex arguements' do
    it 'passes if the block raises an exception of the same class and includes the string in its message' do
      expect { fail ArgumentError.new('with a message') }.to raise_error(ArgumentError, /message/)
    end

    it "fails if the block raises an exception of the same class and but doesn't include the string in its message" do
      message =
        'Block expected to raise error of type ArgumentError with message ' \
        "matching #{/different/.inspect}"

      expect_failure(message) do
        expect { fail ArgumentError.new('with a message') }.to raise_error(ArgumentError, /different/)
      end
    end

    it 'fails if the block raises an exception of a different class' do
      message =
        'Block expected to raise error of type ZeroDivisionError with message' \
        " matching #{/message/.inspect} but was "

      expect_failure(message) do
        expect { fail ArgumentError.new('with a message') }.to raise_error(ZeroDivisionError, /message/)
      end
    end
  end

  it 'raise_exception is an alias of raise_error' do
    expect { 1 / 0 }.to raise_exception(ZeroDivisionError)
  end
end
