module GoodJob
  class BaseJobHandler
    include Logging
    def run(job)
      logger.info "Start to run job: #{job.id}"

      logger.info "Finished the job: #{job.id}"
    end
  end
end
