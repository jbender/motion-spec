# -*- encoding : utf-8 -*-
describe 'Matcher::Change' do
  class TestClass
    attr_reader :counter
    def initialize
      @counter = 0
    end

    def add
      @counter += 1
    end

    def dont_add; end
  end

  before { @test_object = TestClass.new }

  context 'when the expected block changes the argument block' do
    it 'passes' do
      expect { @test_object.add }.to change { @test_object.counter }
    end
  end

  context "when the expected block doesn't change the argument block" do
    it 'fails' do
      expect_failure('Block expected to change value') do
        expect { @test_object.dont_add }.to change { @test_object.counter }
      end
    end

    it 'passes when asked not_to' do
      expect { @test_object.dont_add }.not_to change { @test_object.counter }
    end
  end

  context "when specified 'by'" do
    it 'passes when changes are by the given amount'  do
      expect do
        @test_object.add
        @test_object.add
      end.to change { @test_object.counter }.by(2)
    end

    it 'fails when changes are by a different amount' do
      expect_failure('Block expected to change value by 6 but changed by 2') do
        expect do
          @test_object.add
          @test_object.add
        end.to change { @test_object.counter }.by(6)
      end
    end

    it 'fails when changes are by the given amount but asked not to' do
      expect_failure('Block not expected to change value by 2') do
        expect do
          @test_object.add
          @test_object.add
        end.not_to change { @test_object.counter }.by(2)
      end
    end
  end
end
