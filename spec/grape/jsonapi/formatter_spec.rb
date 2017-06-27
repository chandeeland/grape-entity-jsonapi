class Grape::Json
end

describe Grape::Jsonapi::Formatter do
  subject { JSON.parse(described_class.call(data, {})) }

  context 'compound-documents' do

    let(:fresh_class) do
      class CCCformat < Grape::Jsonapi::Entity::Resource
        attribute :name
      end

      class BBBformat < Grape::Jsonapi::Entity::Resource
        attribute :name
        nest :size, using: CCCformat
      end

      class AAAformat < Grape::Jsonapi::Entity::Resource
        attribute :color
        nest :parent, using: BBBformat
      end

      AAAformat
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
        'type' => 'aaaformats',
        'attributes' => {
          'color' => 'blue'
        },
        'relationships' => {
          'parent' => {
            'data' => { 'id' => 222, 'type' => 'bbbformats' }
          }
        },
        'included' => [
          {
            'id' => 222,
            'type' => 'bbbformats',
            'attributes' => {
              'name' => 'tshirt'
            },
            'relationships' => {
              'size' => {
                'data' => [
                  { 'id' => 333, 'type' => 'cccformats' },
                  { 'id' => 444, 'type' => 'cccformats' }
                ]
              }
            }
          },
          {
            'id' => 333,
            'type' => 'cccformats',
            'attributes' => {
              'name' => 'Small'
            }
          },
          {
            'id' => 444,
            'type' => 'cccformats',
            'attributes' => {
              'name' => 'Med'
            }
          }
        ]
      }
    end

    before do
      allow(::Grape::Json).to receive(:dump).and_return(data)
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
