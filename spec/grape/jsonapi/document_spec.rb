describe Grape::Jsonapi::Document do
  subject { described_class.top(resource) }

  let(:resource) do
    class AAAdoc < Grape::Jsonapi::Entity::Resource
      attribute :color
    end

    AAAdoc
  end

  it 'gives an decendant of Entity::Top' do
    expect(subject.superclass).to be Grape::Jsonapi::Entity::Top

    data = subject.root_exposures.select { |x| x.attribute == :data }.first.send(:options)
    expect(data[:using]).to eq resource

    expect(subject.name).to eq 'Grape::Jsonapi::Document::TopAAAdoc'
  end

  context 'with a module' do
    let(:resource) do
      module ZZZ
        class BBBdoc < Grape::Jsonapi::Entity::Resource
          attribute :color
        end
      end

      ZZZ::BBBdoc
    end

    it 'gives an decendant of Entity::Top' do
      expect(subject.superclass).to be Grape::Jsonapi::Entity::Top

      data = subject.root_exposures.select { |x| x.attribute == :data }.first.send(:options)
      expect(data[:using]).to eq resource

      expect(subject.name).to eq 'Grape::Jsonapi::Document::TopBBBdoc'
    end
  end
end
