describe Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError do
  describe 'MESSAGE' do
    it 'is the not unsupported media type error message' do
      expect(Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError::MESSAGE)
        .to eq('Content-Type must be JSON API-compliant')
    end
  end
end
