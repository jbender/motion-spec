# -*- encoding : utf-8 -*-
describe 'Matcher::StartWith' do
  context 'when the subject starts with the given string' do
    it('passes') { expect('super').to start_with('sup') }

    it 'fails when asked if it does not' do
      expect_failure("\"super\" not expected to start with \"sup\"") do
        expect('super').to_not start_with('sup')
      end
    end
  end

  context "when the subject doesn't start with the given string" do
    it 'fails' do
      expect_failure("\"super\" expected to start with \"key\"") do
        expect('super').to start_with('key')
      end
    end
  end
end
