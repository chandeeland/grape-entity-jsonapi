describe Grape::Jsonapi::Exceptions::NotAcceptableError do
  describe 'MESSAGE' do
    it 'is the not acceptable error message' do
      expect(Grape::Jsonapi::Exceptions::NotAcceptableError::MESSAGE)
        .to eq('Not Acceptable')
    end
  end
end
