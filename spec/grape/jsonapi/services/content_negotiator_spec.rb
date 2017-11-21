describe Grape::Jsonapi::Services::ContentNegotiator do
  describe 'VALID_MEDIA_TYPE' do
    it 'is the JSON API compliant media type' do
      expect(Grape::Jsonapi::Services::ContentNegotiator::VALID_MEDIA_TYPE)
        .to eq('application/vnd+json')
    end
  end

  describe '#run' do
    let(:accept_header) { 'application/vnd+json' }
    let(:content_type)  { 'application/vnd+json' }

    subject do
      Grape::Jsonapi::Services::ContentNegotiator.run(accept_header, content_type)
    end

    context 'when the headers are JSON API compliant' do
      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the headers contain a Content-Type with any media type parameters' do
      let(:content_type) { 'application/vnd+json; version=1' }

      let(:unsupported_media_type_error) do
        Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError
      end

      it 'raises UnsupportedMediaTypeError' do
        expect { subject }.to raise_exception(unsupported_media_type_error, unsupported_media_type_error::MESSAGE)
      end
    end

    context 'when the headers contains the JSON API media type and all instances of that media type are modified with media type parameters' do
      let(:accept_header) do
        'application/vnd.geoffrey-v20170505+json; version=1'
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
