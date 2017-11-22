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
      Grape::Jsonapi::Services::ContentNegotiator.run(
        accept_header:  accept_header,
        content_type:   content_type
      )
    end

    context 'when the headers are JSON API compliant' do
      context 'when the Content-Type is the correct media type' do
        it 'is true' do
          expect(subject).to eq(true)
        end
      end

      context 'when the Accept header contains no media type' do
        let(:accept_header) { nil }

        it 'is true' do
          expect(subject).to eq(true)
        end
      end
    end

    context 'when the headers are not JSON API compliant' do
      let(:unsupported_media_type_error) do
        Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError
      end

      let(:not_acceptable_error) do
        Grape::Jsonapi::Exceptions::NotAcceptableError
      end

      context 'when the Content-Type has any media type parameters' do
        let(:content_type) { 'application/vnd+json; version=1' }

        it 'raises UnsupportedMediaTypeError' do
          expect { subject }
            .to raise_exception(
              unsupported_media_type_error,
              unsupported_media_type_error::MESSAGE
            )
        end
      end

      context 'when the Accept header contains the JSON API media type and all instances of that media type are modified with media type parameters' do
        let(:accept_header) { 'application/vnd+json; version=1' }

        it 'raises NotAcceptableError' do
          expect { subject }
            .to raise_exception(
              not_acceptable_error,
              not_acceptable_error::MESSAGE
            )
        end
      end

      context 'when the Content-Type is invalid' do
        let(:content_type) { 'some-invalid-content-type' }

        it 'raises UnsupportedMediaTypeError' do
          expect { subject }
            .to raise_exception(
              unsupported_media_type_error,
              unsupported_media_type_error::MESSAGE
            )
        end
      end

      context 'when the Content-Type header contains no media type' do
        let(:content_type) { nil }

        it 'raises UnsupportedMediaTypeError' do
          expect { subject }
            .to raise_exception(
              unsupported_media_type_error,
              unsupported_media_type_error::MESSAGE
            )
        end
      end
    end
  end
end
