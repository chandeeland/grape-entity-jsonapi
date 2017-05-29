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
  end
end
