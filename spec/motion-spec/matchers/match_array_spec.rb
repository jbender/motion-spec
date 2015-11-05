# -*- encoding : utf-8 -*-
describe 'Matcher::MatchArray' do
  it 'match_array passes when subject has the same items as value' do
    expect([1, 2, 3, 4]).to match_array([4, 2, 1, 3])
  end

  it 'match_array fails when subject has less items than value' do
    message = "#{[1, 2, 3]} expected to match array #{[1, 2, 3, 4]}"
    expect_failure(message) do
      expect([1, 2, 3]).to match_array([1, 2, 3, 4])
    end
  end

  it 'match_array fails when subject has more items than value' do
    message = "#{[1, 2, 3, 4]} expected to match array #{[1, 2, 4, 4, 3]}"

    expect_failure(message) do
      expect([1, 2, 3, 4]).to match_array([1, 2, 4, 4, 3])
    end
  end

  it 'match_array fails when subject has different items' do
    expected_array = [Object.new, 'a', 2, 3]
    message = "#{[1, 2, 3, 4]} expected to match array #{expected_array}"

    expect_failure(message) do
      expect([1, 2, 3, 4]).to match_array(expected_array)
    end
  end

  it 'match_array fails when subject matches the array but asked not to' do
    message = "#{[1, 2, 3, 4]} not expected to match array"

    expect_failure(message) do
      expect([1, 2, 3, 4]).to_not match_array([4, 2, 1, 3])
    end
  end
end
