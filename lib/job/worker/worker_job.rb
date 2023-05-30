module GoodJob
  module Job
    class WorkerJob < BaseJob
      attr_reader :parent_id, :job_type
      def initialize(id, parent_id)
        super(id)
        @parent_id = parent_id
        @complexity = :worker
      end

      def ready_to_mark_as_done?
        self.initialized? && self.done?
      end

      def initialized?
        raise NotImplementedError
      end

      def status_report
        self.status
      end

      def execute(_job_handler = nil)
        _job_handler.run(self)
      end
    end
  end
end
