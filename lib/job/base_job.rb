module Job
  class BaseJob
    include Logging
    include Stats
    include Manual

    attr_reader :id, :complexity

    def initialize(id)
      @id = id
      @cache = Store.instance
    end

    def execute(_job_handler = nil)
      raise NotImplementedError
    end

    def archive
      { done: true, message: "This job is done and archived at time: #{DateTime.now}" }
    end

    def clean
      @cache.del(id)
    end

    def finalize
      yield
      mark_as_done
    end

    def status_report
      raise NotImplementedError
    end

    def ready_to_mark_as_done?
      raise NotImplementedError
    end

    def done?
      @cache.get(id).to_s.downcase == 'true'
    end

    def to_hash
      raise NotImplementedError
    end

    def self.from_hash(_job_hash)
      raise NotImplementedError
    end

    def save_as_pending
      @cache.set(id, false)
    end

    def mark_as_done
      @cache.set(id, true)
    end
  end
end