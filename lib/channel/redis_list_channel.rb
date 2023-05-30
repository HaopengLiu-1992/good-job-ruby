require 'redis'
require_relative 'base_channel'

module GoodJob
  module Channel
    class RedisListChannel < BaseChannel
      def initialize
        super
        @name = ENV.fetch('REDIS_CHANNEL', 'GOOD_JOB::CHANNEL').to_s
        logger.info "Initalizing Redis Channel: #{@name}"
        @redis = Redis.new
      end

      def publish_job(job)
        logger.info "Publish job #{job} to Channel: #{name}"
        @redis.lpush(name, job)
      end

      def get_job
        @redis.lpop(name)
      end
    end
  end
end
