module GoodJob
  module Job
    class AdminJob < BaseJob
      attr_reader :children, :children_generated

      def initialize(id)
        super(id)
        @complexity = :admin
        @children = []
      end

      def status_report
        status_hash = {}
        children.each do |child|
          status_hash[child.id] = child.done?
        end
        status_hash
      end

      def ready_to_mark_as_done?
        done = children_generated
        children.each do |child|
          done = false unless child.done?
        end
        done
      end
    end
  end
end
