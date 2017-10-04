describe Grape::Jsonapi::Parameters::Filter do
  let(:valid_keys) { %i[aaa bbb ccc] }

  context '#allow' do
    subject { described_class.allow(valid_keys) }

    it 'makes a filter class' do
      expect(subject).to respond_to(:valid_keys)
      expect(subject.valid_keys).to eq valid_keys
    end
  end

  context '#default' do
    subject { described_class.allow(valid_keys).default(default_params) }
    let(:default_params) { { foo: 'bar' } }

    it 'creates default params for the filter' do
      expect(subject.new.query_params).to eq(foo: [%w[eq bar]])
    end

    it 'allows modifications to the default params' do
      new_filter = subject.parse(JSON.unparse(foo: 'baz'))
      expect(new_filter.query_params).to eq(foo: [%w[eq baz]])
    end

    context 'when including default params' do
      let(:valid_keys) { ['cat'] }

      it 'allows modification to valid keys' do
        new_filter = subject.parse(JSON.unparse(cat: 'dog'))
        expect(new_filter.query_params).to eq(foo: [%w[eq bar]], cat: [%w[eq dog]])
      end
    end
  end

  context '#parse' do
    subject { described_class.allow(valid_keys).parse(json) }

    context 'when using implied operation EQ' do
      context 'unparseable error' do
        let(:json) { '{ not valid json' }

        it 'throws a json exception' do
          expect { subject }.to raise_error(JSON::ParserError)
        end
      end

      context 'bad values' do
        let(:json) { JSON.unparse(aaa: {}) }

        it 'throws an exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            'Invalid type for aaa'
          )
        end
      end

      context 'bad values in an array' do
        let(:json) { JSON.unparse(aaa: [{}, 1, 2]) }

        it 'throws an exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            '["aaa has invalid array member, {}"]'
          )
        end
      end

      context 'one forbidden key' do
        let(:json) { JSON.unparse(aaa: 123, zzz: 123) }

        it 'throws an invalid key exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            'Invalid filter keys, [:zzz]'
          )
        end
      end
      context 'multi forbidden key' do
        let(:json) { JSON.unparse(yyy: 123, zzz: 123) }

        it 'raises an exception with and array of errors' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            'Invalid filter keys, [:yyy, :zzz]'
          )
        end
      end
    end
    context 'when using explicit operations' do
      context 'bad operation' do
        let(:json) do
          JSON.unparse(aaa: { zz: 1 })
        end

        it 'ok' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            %(["aaa: Invalid operation 'zz', should be one of eq, gt, gte, lt, lte, ne, in"])
          )
        end
      end

      %w[gt gte lt lte ne].each do |operation|
        context "#{operation} operation" do
          context 'when operant is not scalar' do
            let(:json) do
              JSON.unparse(aaa: { operation.to_sym => [1, 2, 3] })
            end

            it 'fails with error' do
              expect { subject }.to raise_error(
                Grape::Jsonapi::Exceptions::FilterError,
                '["Expected scalar type for aaa using ' + operation + '"]'
              )
            end
          end
        end
      end

      context 'IN operation' do
        context 'when operant is not an array' do
          let(:json) do
            JSON.unparse(aaa: { in: 234 })
          end

          it 'fails with error' do
            expect { subject }.to raise_error(
              Grape::Jsonapi::Exceptions::FilterError,
              %(["aaa 'in' operation requires an array"])
            )
          end
        end
        context 'when operant array has weird members' do
          let(:json) do
            JSON.unparse(aaa: { in: [2, 3, 4, {}] })
          end

          it 'fails with error' do
            expect { subject }.to raise_error(
              Grape::Jsonapi::Exceptions::FilterError,
              %(["aaa has invalid array member, {}"])
            )
          end
        end
      end
    end
  end

  module ActiveRecord
    class Base < RSpec::Mocks::Double; end
  end
  module Mongoid
    class Document < RSpec::Mocks::Double; end
  end

  context '.query_for' do
    context 'mongoid model' do
      let(:model) { Mongoid::Document.new }
      subject do
        described_class
          .allow(valid_keys)
          .parse(json)
          .query_for(model)
      end

      let(:query) { double(:query) }

      before do
        model
        allow(model).to receive(:all).and_return(model)
      end

      context 'eq and in' do
        let(:json) { JSON.unparse(aaa: 123, bbb: [2, 3, 4]) }
        before do
          allow(model).to receive(:where).and_return(query)
          allow(query).to receive(:in).and_return(query)
        end
        it 'it calls mutators on the model' do
          expect(subject).to eq query
          expect(model).to have_received(:where).with(aaa: 123)
          expect(query).to have_received(:in).with(bbb: [2, 3, 4])
        end
      end

      context 'gte and ne' do
        let(:json) { JSON.unparse(aaa: { gte: 123 }, bbb: { ne: 44 }) }
        before do
          allow(model).to receive(:gte).and_return(query)
          allow(query).to receive(:ne).and_return(query)
        end
        it 'it calls mutators on the model' do
          expect(subject).to eq query
          expect(model).to have_received(:gte).with(aaa: 123)
          expect(query).to have_received(:ne).with(bbb: 44)
        end
      end
    end

    context 'active record model' do
      let(:model) { ActiveRecord::Base.new }

      subject do
        described_class
          .allow(valid_keys)
          .parse(json)
          .query_for(model)
      end

      let(:query) { double(:query) }

      before do
        model
        allow(model).to receive(:all).and_return(model)
      end

      context 'eq and in' do
        let(:json) { JSON.unparse(aaa: 123, bbb: [2, 3, 4]) }
        before do
          allow(model).to receive(:where).and_return(query)
          allow(query).to receive(:where).and_return(query)
        end

        it 'it calls mutators on the model' do
          expect(subject).to eq query
          expect(model).to have_received(:where).with(aaa: 123)
          expect(query).to have_received(:where).with(bbb: [2, 3, 4])
        end
      end

      context 'gte and ne' do
        let(:json) { JSON.unparse(aaa: { gte: 123 }, bbb: { ne: 44 }) }
        before do
          allow(model).to receive(:where).and_return(query)
          allow(query).to receive(:where_not).and_return(query)
        end
        it 'it calls mutators on the model' do
          expect(subject).to eq query
          expect(model).to have_received(:where).with('aaa >= ?', 123)
          expect(query).to have_received(:where_not).with(bbb: 44)
        end
      end
    end
  end
end
