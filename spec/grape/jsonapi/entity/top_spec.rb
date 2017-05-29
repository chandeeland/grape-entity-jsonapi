describe Grape::Jsonapi::Entity::Top do
  context 'when there are :included resources' do
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
