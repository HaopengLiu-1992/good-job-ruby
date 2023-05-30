require_relative '../executor'

module GoodJob
  module Role
    class Admin < Executor
      ADMIN_SLEEP_INTERVAL = 10

      def initialize(_options = {})
        @type = :admin
        super
        @sleep_interval = ADMIN_SLEEP_INTERVAL
        # Only enable this workers management feature in one admin host
        @enable_workers_management = (ENV.fetch('WORKERS_MANAGEMENT', false).to_s == 'true')
        @yellow_worker_threshold = Worker::WORKER_SLEEP_INTERVAL * 3
        @red_worker_threshold = Worker::WORKER_SLEEP_INTERVAL * 10
      end

      def start
        super do
          logger.info "#{name} will publish jobs to channel: #{@channel.name}"
        end
        workers_management if @enable_workers_management
      end

      def stop
        super
        @workers_management_thread.kill unless @workers_management_thread.nil?
      end

      def get_workers_status
        statuses = { green: [], yellow: [], red: [] }
        report_role_statuses(:worker).each do |k, v|
          statuses[liveness_status(v)] << k
        end
        message = "Green: live, Yellow: last updated between #{@yellow_worker_threshold}s and #{@red_worker_threshold}s"
        { statuses: statuses, message: message }
      end

      def process_job(job)
        if job.complexity != :admin
          logger.error "Unable to process job #{job.id} in #{name} because job complexity is: #{job.complexity}"
          return
        end
        Thread.start do
          logger.info "#{name} start processing complex job: #{job.id}"
          register_job(job)
          job.execute do |child_job|
            if child_job.done?
              logger.warn "Job: #{child_job.id} is done, ignoring..."
            else
              @channel.publish_job(encode_job(child_job))
            end
          end
        end
      end

      def cancel_job(job_id)
        if @active_jobs.include?(job_id)
          @cache.add_job(@cancelled_jobs_poll, job_id, true)
          unregister_job(@active_jobs[job_id])
          @active_jobs.delete(job_id)
          msg = "Job :#{job_id} is cancelled"
          cancelled = true
        else
          msg = "Job :#{job_id} is not active"
          cancelled = false
        end
        logger.info msg
        { message: msg, cancelled: cancelled }
      end

      def workers_management
        @workers_management_thread = Thread.start do
          redis_worker_key = self.class.get_role_prefix(:worker)
          loop do
            workers = report_role_statuses(:worker).keys.clone
            workers.each do |worker_name|
              last_update = @cache.get_last_registered_time_by_name(redis_worker_key, worker_name)
              status = liveness_status(last_update)
              if status == :red
                logger.warn "Worker: #{worker_name} is not reporting status in the last #{@red_worker_threshold}s, republish worker's current jobs to the channel!"
                @cache.get_all_jobs_by_full_name(worker_name).each { |_, encoded_job| @channel.publish_job(encoded_job) }
                @cache.unregister_worker(redis_worker_key, worker_name)
              elsif status == :yellow
                logger.warn "Worker: #{worker_name} is not reporting status in the last #{@yellow_worker_threshold}s, it might went down!"
              elsif status == :green
                logger.info "Worker: #{worker_name} is green!"
              end
            end
            sleep @red_worker_threshold
          end
        end
      end

      def liveness_status(last_update)
        diff = Time.now.to_i - last_update.to_i
        if diff > @red_worker_threshold
          :red
        elsif diff > @yellow_worker_threshold
          :yellow
        else
          :green
        end
      end

      def report_role_statuses(role)
        key = self.class.get_role_prefix(role)
        @cache.check_role_statuses(key)
      end
    end
  end
end
