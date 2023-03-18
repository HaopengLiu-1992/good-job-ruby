class RedisListChannel < Channel
  include Logging
  attr_reader :name

  def initialize
    @name = 'Channel'
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
