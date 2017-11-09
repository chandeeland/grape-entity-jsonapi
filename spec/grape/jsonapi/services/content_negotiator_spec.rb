describe Grape::Jsonapi::Services::ContentNegotiator do
  let(:headers) do
    {
      "Host" => "www.example.com",
      "Accept" => "application/vnd.geoffrey-v20170505+json",
      "Authorization" => "Bearer testToken123",
      "Cookie" => ""
    }
  end

  subject do
    Grape::Jsonapi::Services::ContentNegotiator.new(headers).run
  end

  describe '#run' do
    context 'when the headers contain ' do
      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the headers contains a Content-Type with any media type parameters' do
      let(:headers) do
        {
          "Host" => "www.example.com",
          "Content-Type" => "application/vnd.geoffrey-v20170505+json; version=1",
          "Authorization" => "Bearer testToken123",
          "Cookie" => ""
        }
      end

      it 'is 415 Unsupported Media Type' do
        expect(subject).to eq(415)
      end
    end

    context 'when the headers contains the JSON API media type and all instances of that media type are modified with media type parameters.' do
      let(:headers) do
        {
          "Host" => "www.example.com",
          "Accept" => "application/vnd.geoffrey-v20170505+json; version=1",
          "Authorization" => "Bearer testToken123",
          "Cookie" => ""
        }
      end

      it 'is 406 Not Acceptable' do
        expect(subject).to eq(415)
      end
    end
  end
end