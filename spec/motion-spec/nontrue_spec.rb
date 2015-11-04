# -*- encoding : utf-8 -*-

false_is_not_true = false.should.not.be.true
nil_is_not_true = nil.should.not.be.true

describe 'A non-true value' do
  it 'passes negated tests inside specs' do
    false.should.not.be.true
    nil.should.not.be.true
  end

  it 'passes negated tests outside specs' do
    false_is_not_true.should.be.true
    nil_is_not_true.should.be.true
  end
end
