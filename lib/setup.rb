require 'yaml'

require_relative 'channel/redis_list_channel'
require_relative 'store/redis_store'

module GoodJob
  module Setup
    def self.settings
      unless @env
        @env = {}
        @env['channel'] = GoodJob::Channel::RedisListChannel.instance
        @env['cache'] = GoodJob::Store::RedisStore.instance
      end
      @env
    end
  end
end

