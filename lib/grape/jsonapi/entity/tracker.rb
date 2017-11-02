
module Grape
  module Jsonapi
    module Entity

      module Tracker
        def tracker
          @tracker ||= self.class.try(:parent).try(:tracker) || Exposer::RecurseCounter.new
        end

        def serializable_hash(runtime_options = {})
          opts = runtime_options.merge(dchan: 'foo', tracker: tracker)
          super(opts)
        end
      end
    end
  end

end
