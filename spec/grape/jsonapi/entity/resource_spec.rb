describe Grape::Jsonapi::Entity::Resource do
  let(:fresh_class) { Class.new(described_class) }

  subject { fresh_class }

  context '#fields' do
    subject { fresh_class.root_exposures.map(&:attribute) }
    it 'has correct fields' do
      expect(subject).to eq %i[id json_api_type meta]
    end
  end

  context '#class methods' do
    context '.attribute' do
      subject do
        fresh_class.root_exposures.select { |r| r.attribute == :attributes }
      end

      context 'when no block is passed' do
        before do
          fresh_class.attribute :aaa, :bbb, :ccc
        end

        it 'adds attributes field' do
          expect fresh_class.root_exposures.map(&:attribute).include? :attributes
        end

        it 'correctly nest fields under an :attribute label' do
          expect(subject.count).to eql 1
          expect(subject.first.nested_exposures.size).to eql(3)
          expect(subject.first.nested_exposures.map(&:attribute)).to eql(%i[aaa bbb ccc])
        end
      end

      context 'when block is passed' do
        before do
          fresh_class.attribute(:ddd) do |_object|
            nil
          end
        end

        it 'correctly nest fields under an :attribute label' do
          expect(subject.count).to eql 1
          expect(subject.first.nested_exposures.map(&:attribute)).to eql(%i[ddd])
        end
      end
    end
    context '.nest' do
      before do
        fresh_class.nest :aaa
        fresh_class.nest :bbb
      end

      context ':included' do
        subject do
          fresh_class.root_exposures.select { |r| r.attribute == :included }
        end

        it 'adds :included field' do
          expect(subject.count).to eq 1
        end

        let(:relationships) { subject.first.nested_exposures }
        it 'has :[relative] labels inside' do
          expect(relationships.size).to eq 2
          expect(relationships.map(&:attribute)).to eq %i[aaa bbb]
        end
      end
      context ':relationships' do
        subject do
          fresh_class.root_exposures.select { |r| r.attribute == :relationships }
        end

        it 'adds :relationships field' do
          expect(subject.count).to eq 1
        end

        let(:relationships) { subject.first.nested_exposures }
        it 'has :[relative] labels inside' do
          expect(relationships.size).to eq 2
          expect(relationships.map(&:attribute)).to eq %i[aaa bbb]
        end

        let(:relationships_child) { relationships.first.nested_exposures }
        it 'has a :data label inside' do
          expect(relationships_child.size).to eql(1)
          expect(relationships_child.first.attribute).to eq(:aaa)
          expect(relationships_child.first.key).to eq(:data)
        end

        let(:rel_child_data) { relationships_child.first }
        it 'has correct options' do
          expect(rel_child_data.send(:options).keys).to include(:using)
        end
      end
    end
    context '.represent' do
      subject { fresh_class.represent(data).serializable_hash }

      context 'with a nested object' do
        let(:fresh_class) do
          class BBB < described_class
            attribute :size
          end
          class AAA < described_class
            attribute :color
            nest :parent, using: BBB
          end
          AAA
        end

        context 'nested object is present' do
          let(:data) do
            OpenStruct.new(
              id: 123,
              color: :red,
              parent: OpenStruct.new(
                id: 999,
                size: 'XXL'
              )
            )
          end

          it 'represents' do
            expect(subject[:id]).to eql(123)
            expect(subject[:type]).to eql('aaas')
            expect(subject[:attributes]).to eq(color: :red)
            expect(subject[:relationships]).to have_key :parent
            expect(subject[:relationships][:parent])
              .to have_key :data
            expect(subject[:relationships][:parent][:data]).to eq(
              id: 999,
              type: 'bbbs'
            )
            expect(subject[:included]).to have_key :parent
            expect(subject[:included][:parent][:id]).to eq 999
            expect(subject[:included][:parent][:type]).to eq 'bbbs'
            expect(subject[:included][:parent][:attributes][:size]).to eq 'XXL'
          end
        end

        context 'nested object is missing' do
          let(:data) do
            OpenStruct.new(
              id: 123,
              color: :red,
              parent: nil
            )
          end

          it 'represents' do
            expect(subject[:id]).to eql(123)
            expect(subject[:type]).to eql('aaas')
            expect(subject[:attributes]).to eq(color: :red)
            expect(subject[:relationships]).not_to have_key :parent

            expect(subject[:included]).not_to have_key :parent
          end
        end
      end

      context 'with a nested [ object ]' do
        let(:fresh_class) do
          class GGG < described_class
            attribute :color
            attribute :parents do |object|
              object.parents.map do |p|
                {
                  id: p.id,
                  name: p.size
                }
              end
            end
          end
          GGG
        end

        context 'when the data is present' do
          let(:data) do
            OpenStruct.new(
              id: 123,
              color: :red,
              parents: [
                OpenStruct.new(
                  id: 999,
                  size: 'XXL',
                  extra: 'garbage'
                ),
                OpenStruct.new(
                  id: 888,
                  size: 'XL'
                )
              ]

            )
          end

          it 'represents' do
            expect(subject[:id]).to eql(123)
            expect(subject[:type]).to eql('gggs')
            expect(subject[:attributes]).to include(color: :red)
            expect(subject[:attributes][:parents]).to be_instance_of Array
            expect(subject[:attributes][:parents].count).to eq 2

            expect(subject[:attributes][:parents].first).to eq(id: 999, name: 'XXL')
            expect(subject[:attributes][:parents].last).to eq(id: 888, name: 'XL')
          end
        end


        context 'id is a BSON object that needs to be formatted to string' do
          let(:bson_object) do
            double(:bson_object).tap do |o|
              expect(o).to receive(:class).at_least(:once).and_return(::BSON::ObjectId)
              expect(o).to receive(:to_s).at_least(:once).and_return('id_string')
            end
          end
          let(:fresh_class) do
            class ManCat < described_class
              def self.type
                'man_cats'
              end
              attribute :size
            end
            class AAA < described_class
              attribute :color
              nest :parent, using: ManCat
            end
            AAA
          end

          let(:data) do
            OpenStruct.new(
              id: 123,
              color: :red,
              parent: OpenStruct.new(
                id: bson_object,
                size: 'XXL'
              )
            )
          end

          it 'represents relationships and inclusions correctly' do
            expect(subject[:included][:parent][:attributes][:size]).to eq 'XXL'
            expect(subject[:included][:parent][:id]).to be_a String
            expect(subject[:relationships][:parent][:data]).to eq(
              id: 'id_string',
              type: 'man_cats'
            )
          end
        end

        context 'when the data is []' do
          let(:data) do
            OpenStruct.new(
              id: 123,
              color: :red,
              parents: []
            )
          end

          it 'represents' do
            expect(subject[:id]).to eql(123)
            expect(subject[:type]).to eql('gggs')
            expect(subject[:attributes]).to include(color: :red)
            expect(subject[:attributes][:parents]).to be_instance_of Array
            expect(subject[:attributes][:parents].count).to eq 0
          end
        end
      end

      context 'when the data has an attrbute name of "type"' do
        let(:fresh_class) do
          class MMM < described_class
            attribute :name
            attribute :type
          end
          MMM
        end

        let(:data) do
          OpenStruct.new(
            id: 1, 
            name: 'foo', 
            type: 'bar'
          )
        end

        it 'represents' do
          expect(subject[:id]).to eql(1)
          expect(subject[:type]).to eql('mmms')
          expect(subject[:attributes]).to include(name: 'foo')
          expect(subject[:attributes]).to include(type: 'bar')
        end
      end
    end
  end
end
