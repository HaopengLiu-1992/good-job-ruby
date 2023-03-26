module Store
  class RedisStore < BaseStore
    include Logging
    include Singleton

    def initialize
      @redis = Redis.new
    end

    def set(k, v)
      @redis.set(key(k), v)
    end

    def get(k)
      @redis.get(key(k))
    end

    def del(k)
      @redis.del(key(k))
    end

    def include?(k)
      !@redis.get(key(k)).nil?
    end

    def add_job(namespace, k, v)
      @redis.hset(key(namespace), key(k), v)
    end

    def get_job(namespace, k)
      @redis.hget(key(namespace), key(k))
    end

    def remove_job(namespace, k)
      @redis.hdel(key(namespace), key(k))
    end

    def include_job?(namespace, k)
      !@redis.hget(key(namespace), key(k)).nil?
    end

    def get_all_jobs(namespace)
      @redis.hgetall(key(namespace))
    end

    def get_all_jobs_by_full_name(worker_full_name)
      @redis.hgetall(worker_full_name)
    end

    def register_role_as_live(role, namespace)
      logger.info "Register role #{key(namespace)} as live..."
      @redis.hset(roles_key(role), key(namespace), Time.now.to_i)
    end

    def check_role_statuses(role)
      @redis.hgetall(roles_key(role.to_s))
    end

    def unregister_worker(role, worker_full_name)
      logger.info "Unregister worker #{worker_full_name}..."
      @redis.hdel(roles_key(role), worker_full_name)
      @redis.del(worker_full_name)
    end

    def get_last_registered_time_by_name(role, worker_full_name)
      @redis.hget(roles_key(role.to_s), worker_full_name).to_i
    end

    def roles_key(role)
      key(role + 'S')
    end

    def key(k)
      k
    end
  end
end