# -*- encoding : utf-8 -*-
describe 'Matcher::RespondTo' do
  class TestCase
    def call_me(_a, _b, _c)
    end
  end
  before { @test_object = TestCase.new }

  context 'when subject responds to method name' do
    it('passes') { expect(@test_object).to respond_to(:call_me) }

    context 'with a given number of arguments' do
      it 'passes when the right number' do
        expect(@test_object).to respond_to(:call_me).with(3).arguments
      end

      it 'fails with the wrong number' do
        message =
          "#{@test_object.inspect} expected to respond to #call_me with 2" \
          ' arguments'

        expect_failure(message) do
          expect(@test_object).to respond_to(:call_me).with(2).arguments
        end
      end

      it 'fails with the right number but asked not to' do
        message =
          "#{@test_object.inspect} not expected to respond to #call_me with 3" \
          ' arguments'

        expect_failure(message) do
          expect(@test_object).not_to respond_to(:call_me).with(3).arguments
        end
      end
    end
  end

  context 'when subject does not respond to method name' do
    it 'fails' do
      message = "#{@test_object.inspect} expected to respond to #nonexistent"

      expect_failure(message) do
        expect(@test_object).to respond_to(:nonexistent)
      end
    end
  end
end
