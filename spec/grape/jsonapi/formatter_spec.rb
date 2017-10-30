module Grape
  class Json
  end
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

      Grape::Jsonapi::Document.top(AAAformat)
    end

    let(:resource) do
      OpenStruct.new(
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
      )
    end
    let(:answer_included) do
      [
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
    end
    let(:answer_data) do
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
        }
      }
    end

    context 'with recursive nesting' do
      let(:resource) do
        OpenStruct.new(
          id: 111,
          color: 'blue',
          parent: OpenStruct.new(
            id: 222,
            name: 'tshirt',
            child: OpenStruct.new(
              id: 111,
              color: 'blue'
            )
          )
        )
      end

      let(:answer_included) do
        [
          {
            'id' => 222,
            'type' => 'bbbformats',
            'attributes' => {
              'name' => 'tshirt'
            }
          }
        ]
      end

      let(:fresh_class) do
        class BBBformat < Grape::Jsonapi::Entity::Resource
        end

        class AAAformat < Grape::Jsonapi::Entity::Resource
          attribute :color
          nest :parent, using: BBBformat
        end

        class BBBformat < Grape::Jsonapi::Entity::Resource
          attribute :name
          nest :child, using: AAAformat
        end

        Grape::Jsonapi::Document.top(AAAformat)
      end

      let(:data) do
        fresh_class.represent(data: resource)
      end

      let(:answer) do
        {
          'jsonapi' => { 'version' => '1.0' },
          'data' => answer_data,
          'included' => answer_included
        }
      end

      it 'represents data only one level deep' do
        expect(subject).to have_key('jsonapi')
        expect(subject).to have_key('data')
        expect(subject).to have_key('included')
        expect(subject['data']['id']).to eq(answer['data']['id'])
        expect(subject['data']['id']).to eq(answer['data']['id'])
        expect(subject['data']['type']).to eq(answer['data']['type'])
        expect(subject['data']['attributes']).to eq(answer['data']['attributes'])
        expect(subject['data']['relationships']).to eq(answer['data']['relationships'])
        answer['included'].each do |current|
          expect(subject['included']).to include(current)
        end
      end
    end

    context 'when data is not an array' do
      let(:data) do
        fresh_class.represent(data: resource)
      end

      let(:answer) do
        {
          'jsonapi' => { 'version' => '1.0' },
          'data' => answer_data,
          'included' => answer_included
        }
      end

      it 'collects :included relations' do
        expect(subject).to have_key('jsonapi')
        expect(subject).to have_key('data')
        expect(subject).to have_key('included')
        expect(subject['data']['id']).to eq(answer['data']['id'])
        expect(subject['data']['id']).to eq(answer['data']['id'])
        expect(subject['data']['type']).to eq(answer['data']['type'])
        expect(subject['data']['attributes']).to eq(answer['data']['attributes'])
        expect(subject['data']['relationships']).to eq(answer['data']['relationships'])
        answer['included'].each do |current|
          expect(subject['included']).to include(current)
        end
      end
    end

    context 'when data is an array' do
      let(:data) do
        fresh_class.represent(data: [resource])
      end

      let(:answer) do
        {
          'jsonapi' => { 'version' => '1.0' },
          'data' => [answer_data],
          'included' => answer_included
        }
      end

      it 'collects :included relations' do
        expect(subject).to have_key('jsonapi')
        expect(subject).to have_key('data')
        expect(subject).to have_key('included')
        expect(subject['data'].first['id']).to eq(answer['data'].first['id'])
        expect(subject['data'].first['type']).to eq(answer['data'].first['type'])
        expect(subject['data'].first['attributes']).to eq(answer['data'].first['attributes'])
        expect(subject['data'].first['relationships']).to eq(answer['data'].first['relationships'])
        answer['included'].each do |current|
          expect(subject['included']).to include(current)
        end
      end
    end
  end
end
