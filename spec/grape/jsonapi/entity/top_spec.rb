xdescribe Grape::Jsonapi::Entity::Top do
  context 'when there are :included resources' do
    let(:fresh_class) do
      class Address < Grape::Jsonapi::Entity::Resource
        expose :street
        expose :city
        expose :state
      end

      class User < Grape::Jsonapi::Entity::Resource
        expose :name
        nest :address
      end

      class Chapter < Grape::Jsonapi::Entity::Resource
        expose :page
      end

      class Book < Grape::Jsonapi::Entity::Resource
        expose :title
        nest :author, using: User
        nest :chapters, using: Chapter
      end

      Book
    end

    let(:data) do
      OpenStruct.new(
        id: 111,
        title: 'Alice In Wonderland',
        author: OpenStruct.new(
          id: 222,
          name: 'Lewis Carroll',
          address: OpenStruct.new(
            street: '123 fake st',
            city: 'springfield',
            state: 'WY'
          )
        ),
        chapters: [
          OpenStruct.new(id: 300, page: 3),
          OpenStruct.new(id: 301, page: 20),
          OpenStruct.new(id: 302, page: 30),
          OpenStruct.new(id: 303, page: 50)
        ]
      )
    end

    subject { descri.represent(data).serializable_hash }

    it 'has correct fields' do
      expect(subject[:id]).to eq 111
      expect(subject[:type]).to eq 'books'
      expect(subject[:attributes]).to eq(title: 'Alice In Wonderland')
      expect(subject[:relationships].keys).to %i[author chapters]
      expect(subject[:included].keys).to %i[author chapters]
    end
  end
end
