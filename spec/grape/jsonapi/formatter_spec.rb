module Grape
  class Json
  end
end

describe Grape::Jsonapi::Formatter do
  subject { JSON.parse(described_class.call(data, {})) }

  context 'nested entities conditionally' do
    let(:fresh_class) do
      class FirstFormat < Grape::Jsonapi::Entity::Resource
        attribute :object_type
      end

      class SecondFormat < Grape::Jsonapi::Entity::Resource
        attribute :object_type
      end

      class NestedClass < Grape::Jsonapi::Entity::Resource
        attribute :name
        nest :first, using: FirstFormat, if: lambda { |object, _options| object.object_type == "First" }
        nest :second, using: SecondFormat, if: lambda { |object, _options| object.object_type == "Second" }
      end

      Grape::Jsonapi::Document.top(NestedClass)
    end

    let(:first_resource) do
      OpenStruct.new(
        id: 111,
        name: 'nested_class',
        format_type: OpenStruct.new(
          id: 222,
          object_type: "First"
        )
      )
    end

    let(:second_resource) do
      OpenStruct.new(
        id: 111,
        name: 'nested_class',
        format_type: OpenStruct.new(
          id: 333,
          object_type: "Second"
        )
      )
    end

    let(:first_answer_included) do
      [
        {
          'id' => 222,
          'type' => 'firstformats',
          'attributes' => {
            'object_type' => 'First'
          }
        }
      ]
    end
    let(:first_answer_data) do
      {
        'id' => 111,
        'type' => 'nestedclasses',
        'attributes' => {
          'name' => 'nested_class'
        },
        'relationships' => {
          'format_type' => {
            'data' => { 'id' => 222, 'type' => 'firstformats' }
          }
        }
      }
    end

    let(:second_answer_included) do
      [
        {
          'id' => 222,
          'type' => 'secondformats',
          'attributes' => {
            'object_type' => 'Second'
          }
        }
      ]
    end
    let(:second_answer_data) do
      {
        'id' => 111,
        'type' => 'nestedclasses',
        'attributes' => {
          'name' => 'nested_class'
        },
        'relationships' => {
          'format_type' => {
            'data' => { 'id' => 222, 'type' => 'secondformats' }
          }
        }
      }
    end

    context 'when specifying type of entity to use to represent nested relationships' do
      let(:first_data) do
        fresh_class.represent(data: first_resource)
      end

      let(:second_data) do
        fresh_class.represent(data: second_resource)
      end

      let(:first_answer) do
        {
          'jsonapi' => { 'version' => '1.0' },
          'data' => first_answer_data,
          'included' => first_answer_included
        }
      end

      let(:second_answer) do
        {
          'jsonapi' => { 'version' => '1.0' },
          'data' => second_answer_data,
          'included' => second_answer_included
        }
      end

      it 'represents the data correctly (FirstFormat)' do
        first_response = JSON.parse(described_class.call(first_data, {}))

        expect(first_response).to have_key('jsonapi')
        expect(first_response).to have_key('data')
        expect(first_response).to have_key('included')
        expect(first_response['data']['id']).to eq(first_answer['data']['id'])
        expect(first_response['data']['id']).to eq(first_answer['data']['id'])
        expect(first_response['data']['type']).to eq(first_answer['data']['type'])
        expect(first_response['data']['attributes']).to eq(first_answer['data']['attributes'])
        expect(first_response['data']['relationships']).to eq(first_answer['data']['relationships'])
        first_answer['included'].each do |current|
          expect(first_response['included']).to include(current)
        end
      end

      it 'represents the data correctly (SecondFormat)' do
        second_response = JSON.parse(described_class.call(first_data, {}))

        expect(second_response).to have_key('jsonapi')
        expect(second_response).to have_key('data')
        expect(second_response).to have_key('included')
        expect(second_response['data']['id']).to eq(second_answer['data']['id'])
        expect(second_response['data']['id']).to eq(second_answer['data']['id'])
        expect(second_response['data']['type']).to eq(second_answer['data']['type'])
        expect(second_response['data']['attributes']).to eq(second_answer['data']['attributes'])
        expect(second_response['data']['relationships']).to eq(second_answer['data']['relationships'])
        second_answer['included'].each do |current|
          expect(second_response['included']).to include(current)
        end
      end
    end
  end

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
