describe Grape::Jsonapi::Entity::ResourceIdentifier do
  class Cow < described_class
  end

  class Mouse < described_class
  end

  context '#type' do
    let(:plural) { 'cats' }
    let(:single) { 'cat' }

    subject do
      fresh_class.represent(data).serializable_hash
    end

    context 'when entity has root set' do
      let(:fresh_class) { Cow }
      before { fresh_class.root(plural, single) }

      context 'when object includes :type field' do
        let(:data) do
          { id: 123, type: 'dogs' }
        end

        it 'should show object.type' do
          expect(subject).to include(type: 'dogs')
        end
      end

      context 'when object does not include :type field' do
        let(:data) do
          { id: 123 }
        end

        it 'uses the entity root' do
          expect(subject).to include(type: 'cats')
        end
      end

      context 'when object is plural' do
        let(:data) do
          [{ id: 123 }, { id: 234 }]
        end

        subject do
          fresh_class.represent(data).map(&:serializable_hash)
        end

        it 'shows plural correctly' do
          expect(subject).to eq [{ type: 'cats', id: 123 }, { type: 'cats', id: 234 }]
        end
      end
    end

    context ' when the entity has no root set' do
      let(:fresh_class) { Mouse }

      context 'when object includes :type field' do
        let(:data) do
          { id: 123, type: 'dogs' }
        end

        it 'should show object.type' do
          expect(subject).to include(type: 'dogs')
        end
      end

      context 'when object does not include :type field' do
        let(:data) do
          { id: 123 }
        end

        it 'uses the entity class name' do
          expect(subject).to include(type: 'mice')
        end
      end
    end
  end
end
