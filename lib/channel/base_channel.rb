require 'singleton'
require_relative '../logging'
module GoodJob
  module Channel
    class BaseChannel
      include Singleton
      include Logging

      attr_reader :name

      def publish_job(_job)
        raise NotImplementedError
      end

      def get_job
        raise NotImplementedError
      end
    end
  end
end
