describe Grape::Jsonapi::Exceptions::NotAcceptableError do
  describe 'MESSAGE' do
    it 'is the not acceptable error message' do
      expect(Grape::Jsonapi::Exceptions::NotAcceptableError::MESSAGE)
        .to eq('Accept header must be JSON API-compliant')
    end
  end
end
