describe Grape::Jsonapi::Services::ContentNegotiator do
  let(:base_headers) do
    {
      'Host' => 'www.example.com',
      'Authorization' => 'Bearer testToken123',
      'Cookie' => ''
    }
  end

  subject do
    Grape::Jsonapi::Services::ContentNegotiator.run(headers)
  end

  describe 'VALID_MEDIA_TYPE' do
    it 'is the JSON API compliant media type' do
      expect(Grape::Jsonapi::Services::ContentNegotiator::VALID_MEDIA_TYPE)
        .to eq('application/vnd+json')
    end
  end

  describe '#run' do
    context 'when the headers are JSON API compliant' do
      let(:headers) do
        base_headers.merge('Content-Type' => 'application/vnd+json')
      end

      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the headers contain a Content-Type with any media type parameters' do
      let(:headers) do
        base_headers.merge('Content-Type' => 'application/vnd+json; version=1')
      end

      let(:unsupported_media_type_error) do
        Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError
      end

      it 'raises UnsupportedMediaTypeError' do
        expect { subject }.to raise_exception(unsupported_media_type_error, unsupported_media_type_error::MESSAGE)
      end
    end

    context 'when the headers contains the JSON API media type and all instances of that media type are modified with media type parameters' do
      let(:headers) do
        base_headers.merge(
          'Accept' => 'application/vnd.geoffrey-v20170505+json; version=1'
        )
      end

      let(:not_acceptable_error) do
        Grape::Jsonapi::Exceptions::NotAcceptableError
      end

      it 'is 406 Not Acceptable' do
        expect { subject }.to raise_exception(not_acceptable_error, not_acceptable_error::MESSAGE)
      end
    end
  end
end
