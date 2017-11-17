describe Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError do
  describe 'MESSAGE' do
    it 'is the not unsupported media type error message' do
      expect(Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError::MESSAGE)
        .to eq('Unsupported Media Type')
    end
  end
end
