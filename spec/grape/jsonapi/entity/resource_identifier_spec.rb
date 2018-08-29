describe Grape::Jsonapi::Entity::ResourceIdentifier do
  class Cow < described_class
  end

  class Mouse < described_class
  end

  class HorseDog < described_class
    def json_api_type
      self.class.name.split('::').last.underscore.pluralize
    end
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
          { id: 123, json_api_type: 'dogs' }
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
          { id: 123, json_api_type: 'dogs' }
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

      context 'when then entity class is multi worded' do
        let(:fresh_class) { HorseDog }
        let(:data) do
          { id: 123 }
        end

        it 'uses the entity class name underscored' do
          expect(subject).to include(type: 'horse_dogs')
        end
      end
    end
  end

  context '#custom_id_proc' do
    subject do
      fresh_class.represent(data).serializable_hash
    end

    let(:record_id) { 'ID' }
    let(:alternate_id_attribute) { 'ALT_ID_A' }
    let(:alternate_id_block) { 'ALT_ID_B' }
    let(:data) do
      OpenStruct.new(
        id: record_id,
        other_attribute: alternate_id_attribute,
      )
    end

    context 'when custom id is specified' do
      let(:fresh_class) { Cow }

      context 'as an attribute name' do
        before { fresh_class.entity_id :other_attribute }

        it 'uses the custom id' do
          expect(subject[:id]).to eq alternate_id_attribute
        end
      end

      context 'as a block' do
        before { fresh_class.entity_id { |obj| alternate_id_block } }

        it 'uses the custom id' do
          expect(subject[:id]).to eq alternate_id_block
        end
      end

    end

    context 'when custom id is not specified' do
      let(:fresh_class) { Mouse }

      it 'uses the record id' do
        expect(subject[:id]).to eq record_id
      end
    end

  end
end
