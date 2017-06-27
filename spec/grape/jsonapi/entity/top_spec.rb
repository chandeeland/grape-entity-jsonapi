describe Grape::Jsonapi::Entity::Top do
  let(:fresh_class) do
    class Address < Grape::Jsonapi::Entity::Resource
      expose :street
      expose :city
      expose :state
    end

    Class.new(described_class).tap do |klass|
      klass.expose :data, using: Address
    end
  end

  context 'represent' do
    subject { fresh_class.represent(data).serializable_hash }

    context 'when there are errors' do
      let(:error) do
        OpenStruct.new(errorhash)
      end

      let(:errorhash) do
        {
          id: 1111,
          status: 'failure',
          code: 400,
          title: 'broken stuff',
          detail: 'broken stuff details'
        }
      end

      let(:data) { OpenStruct.new(errors: [error]) }

      let(:result) do
        {
          errors: [
            { id: 1111, status: 0, code: 400, title: 'broken stuff', detail: 'broken stuff' }
          ],
          jsonapi: { version: '1.0' },
          data: nil
        }
      end

      context 'when representing an object ' do
        it 'shows errors, instead of data' do
          expect(subject).to eql result
        end
      end

      context 'when representing a hash' do
        let(:error) { errorhash }
        it 'shows errors, instead of data' do
          expect(subject).to eql result
        end
      end
    end
  end

  context 'when there are :included resources' do
    subject { fresh_class.root_exposures.map(&:attribute) }

    it 'has correct root fields' do
      expect(subject).to include :data
      expect(subject).to include :errors
      expect(subject).to include :links
      expect(subject).to include :meta
      expect(subject).to include :jsonapi
    end
  end
end
