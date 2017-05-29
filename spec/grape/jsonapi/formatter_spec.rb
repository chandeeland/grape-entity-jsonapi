describe Grape::Jsonapi::Formatter do
  subject { JSON.parse(described_class.call(data, {})) }

  context 'compound-documents' do
    let(:fresh_class) do
      class CCC < Grape::Jsonapi::Entity::Resource
        attribute :name
      end

      class BBB < Grape::Jsonapi::Entity::Resource
        attribute :name
        nest :size, using: CCC
      end

      class AAA < Grape::Jsonapi::Entity::Resource
        attribute :color
        nest :parent, using: BBB
      end

      AAA
    end

    let(:data) do
      fresh_class.represent(OpenStruct.new(
        id: 111,
        color: 'blue',
        parent: OpenStruct.new(
          id: 222,
          name: 'tshirt',
          size: [
            OpenStruct.new(
              id: 333,
              name: 'Small'
            ),
            OpenStruct.new(
              id: 444,
              name: 'Med'
            )
          ]
        )
      ))
    end

    let(:answer) do
      {
        'id' => 111,
        'type' => 'aaas',
        'attributes' => {
          'color' => 'blue'
        },
        'relationships' => {
          'parent' => {
            'data' => { 'id' => 222, 'type' => 'bbbs' }
          }
        },
        'included' => [
          {
            'id' => 222,
            'type' => 'bbbs',
            'attributes' => {
              'name' => 'tshirt'
            },
            'relationships' => {
              'size' => {
                'data' => [
                  {'id' => 333, 'type' => 'cccs'},
                  {'id' => 444, 'type' => 'cccs'}
                ]
              }
            }
          },
          {
            'id' => 333,
            'type' => 'cccs',
            'attributes' => {
              'name' => 'Small'
            }
          },
          {
            'id' => 444,
            'type' => 'cccs',
            'attributes' => {
              'name' => 'Med'
            }
          }
        ]
      }
    end

    it 'collects :included relations' do
      expect(subject['id']).to eq(answer['id'])
      expect(subject['type']).to eq(answer['type'])
      expect(subject['attributes']).to eq(answer['attributes'])
      expect(subject['relationships']).to eq(answer['relationships'])
      answer['included'].each do |current|
        expect(subject['included']).to include(current)
      end
    end
  end
end
