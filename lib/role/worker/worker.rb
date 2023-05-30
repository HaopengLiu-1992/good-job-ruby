require_relative '../executor'
module GoodJob
  module Role
    class Worker < Executor
      ACTIVE_JOBS_LIMIT = 3
      WORKER_SLEEP_INTERVAL = 20

      def initialize(_options = {})
        @type = :worker
        super
        @sleep_interval = WORKER_SLEEP_INTERVAL
        @job_handler = _options.fetch(:job_handler, nil)
      end

      def start
        super do
          preload_unfinished_jobs
          logger.info "#{name} will subscribe jobs from channel: #{@channel.name}"
        end
      end

      private

      # Override
      def update_status
        super
        pickup_new_jobs
      end

      def pickup_new_jobs
        if @active_jobs.size < ACTIVE_JOBS_LIMIT
          encoded_job = @channel.get_job
          return if encoded_job.nil?
          job_hash = decode_job(encoded_job)
          job = get_job_class(job_hash[:job_type]).from_hash(job_hash)
          if job.complexity == :worker
            logger.info "Adding new job to worker: #{job.id} with parent: #{job.parent_id}"
            if @cache.include_job?(@cancelled_jobs_poll, job.parent_id)
              logger.warn "Not able to process job #{job.id} because #{job.parent_id} has been cancelled"
            elsif job.done?
              logger.warn "Ignoring job #{job} from worker: #{name} because it's done!"
            else
              register_job(job)
              job.execute(@job_handler)
            end
          else
            logger.error "Unable to process job: #{job.id} because it's an #{job.complexity} job!"
          end
        end
      end

      def preload_unfinished_jobs
        @cache.get_all_jobs(name).each do |_, encoded_job|
          job_hash = decode_job(encoded_job)
          job = get_job_class(job_hash[:job_type]).from_hash(job_hash)
          if job.done?
            logger.info "Ignoring job #{job} from worker: #{name} because it's done!"
          else
            @active_jobs[job.id] = job
            job.execute(@job_handler)
          end
        end
      end
    end
  end
end
