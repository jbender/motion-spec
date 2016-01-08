# -*- encoding : utf-8 -*-
describe 'Matcher::BeA' do
  class SpecialString < String
  end

  it 'be_a passes when class is in the inheritance chain' do
    expect(SpecialString).to be_a String
  end

  it "be_a passes when object's class is in the inheritance chain" do
    expect(SpecialString.new).to be_a String
  end

  it 'be_a fails when class is not in the inheritance chain' do
    expect_failure('SpecialString expected to be a kind of Integer') do
      expect(SpecialString).to be_a Integer
    end
  end

  it 'be_a fails when class is not in the inheritance chain' do
    object = SpecialString.new
    expect_failure("#{object} expected to be a kind of Integer") do
      expect(object).to be_a Integer
    end
  end

  it 'be_a fails when class is in the inheritance chain but asked for to_not' do
    expect_failure('SpecialString not expected to be a kind of String') do
      expect(SpecialString).to_not be_a String
    end

    object = SpecialString.new
    expect_failure('not expected to be a kind of String') do
      expect(object).to_not be_a String
    end
  end

  it 'be_a passes when class is in the inheritance chain but asked for to_not' do
    expect(SpecialString).to_not be_a Integer

    object = SpecialString.new
    expect(object).to_not be_a Integer
  end

  it 'be_a is aliased to be_an for proper English' do
    expect(SpecialString).to_not be_an Integer
  end
end
