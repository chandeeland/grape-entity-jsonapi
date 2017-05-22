require 'spec_helper'
require 'ostruct'

describe GrapeEntityJsonapi::Resource do
  let(:fresh_class) { Class.new(described_class) }

  subject { fresh_class }

  context '#fields' do
    subject { fresh_class.root_exposures.map(&:attribute) }
    it 'has correct fields' do
      expect(subject).to eq %i[type id meta]
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
          fresh_class.attribute(:ddd) do
            'do nothing'
          end
        end

        it 'correctly nest fields under an :attribute label' do
          expect(subject.count).to eql 1
          expect(subject.first.nested_exposures.map(&:attribute)).to eql(%i[ddd])
        end
      end
    end

    context '.nest' do
      subject do
        fresh_class.root_exposures.select { |r| r.attribute == :relationships }
      end

      before do
        fresh_class.nest :aaa
      end

      it 'adds :relationships field' do
        expect(subject.count).to eq 1
      end

      let(:relationships) { subject.first.nested_exposures }
      it 'has a :data label inside' do
        expect(relationships.size).to eq 1
        expect(relationships.first.attribute).to eq :data
      end

      let(:relationships_data) { relationships.first.nested_exposures }
      it 'correctly nest fields under an :relationships:data label' do
        expect(relationships_data.size).to eql(1)
        expect(relationships_data.first.attribute).to eq(:aaa)
      end
    end
  end
end
