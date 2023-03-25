module Channel
  class BaseChannel
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

