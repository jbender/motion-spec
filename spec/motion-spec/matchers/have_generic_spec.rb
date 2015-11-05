# -*- encoding : utf-8 -*-
describe 'Matcher::HaveGeneric' do
  it 'have_key passes if the hash includes the given key' do
    expect(a: 1, b: 2, c: 3).to have_key(:c)
  end

  it "have_key fails if the hash doesn't include the given key" do
    message = '{:a=>1, :b=>2, :c=>3} #has_key?(:h) expected to return true'

    expect_failure(message) do
      expect(a: 1, b: 2, c: 3).to have_key(:h)
    end
  end

  context 'value responds to has_color?' do
    class TestClass
      def has_color?(color)
        color == :red
      end
    end

    before { @object = TestClass.new }

    it 'passes when function returns true' do
      expect(@object).to have_color(:red)
    end

    it 'fails when function returns false' do
      message = "#{@object.inspect} #has_color?(:blue) expected to return true"

      expect_failure(message) { expect(@object).to have_color(:blue) }
    end

    it 'fails when function returns true but asked not to' do
      message =
        "#{@object.inspect} #has_color?(:red) not expected to return true"

      expect_failure(message) { expect(@object).to_not have_color(:red) }
    end
  end
end
