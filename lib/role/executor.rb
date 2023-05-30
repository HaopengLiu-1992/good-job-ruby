require 'concurrent'
require 'time'
require 'securerandom'

require_relative '../setup'
require_relative '../manual'
require_relative '../logging'

module GoodJob
  module Role
    class Executor
      include Logging
      include Manual
      include Setup

      attr_reader :name

      def initialize(_options = {})
        @cache = Setup.settings['cache']
        @channel = Setup.settings['channel']
        @active_jobs = Concurrent::Hash.new
        @archived_jobs = Concurrent::Hash.new
        @executor_prefix = self.class.get_role_prefix(@type)
        @name = "#{@executor_prefix}::#{SecureRandom.alphanumeric(10).upcase}"
        @cancelled_jobs_poll = "#{@executor_prefix}::Cancelled_Jobs"
      end

      def start
        @start_thread = Thread.start do
          logger.info "Starting #{name}..."
          yield
          loop do
            update_status
            sleep @sleep_interval
          end
        end
      end

      class << self
        def get_role_prefix(type)
          "#{ENV.fetch('APP_NAME', 'GOOD_JOB')}::#{type.to_s.upcase}"
        end
      end

      def stop
        shutdown
      end

      def shutdown
        unless @start_thread.nil?
          logger.info "Stopping #{name} thread..."
          @start_thread.kill
        end
      end

      def report_job_status
        {
          active_jobs: @active_jobs.keys,
          finished_jobs: @archived_jobs.keys
        }
      end

      def get_job_status(job_id)
        if @active_jobs.include?(job_id)
          job = @active_jobs[job_id]
          {
            job_id: job_id,
            job_exist: true,
            job_live: true,
            job_done: job.done?,
            job_status: job.status_report,
            message: "Job is active!"
          }
        elsif @archived_jobs.include?(job_id)
          {
            job_id: job_id,
            job_exist: true,
            job_live: false,
            job_done: true,
            message: "Found the job record in archived jobs!"
          }
        elsif @cache.get(job_id)
          {
            job_id: job_id,
            job_exist: true,
            job_live: false,
            job_done: @cache.get(job_id),
            message: "Found the job record in cache!"
          }
        else
          {
            job_exist: false,
            job_live: false,
            job_done: false,
            message: "Job #{job_id} is not existing!"
          }
        end
      end

      private

      def update_status
        clean_jobs
      end

      def clean_jobs
        @active_jobs.keys.clone.each do |job_id|
          job = @active_jobs[job_id]
          if job.ready_to_mark_as_done?
            job.finalize
            unregister_job(job)
          end
        end
      end

      def register_job(job)
        @cache.add_job(name, job.id, encode_job(job))
        @active_jobs[job.id] = job
      end

      def unregister_job(job)
        @cache.remove_job(name, job.id)
        @active_jobs.delete(job.id)
        @archived_jobs[job.id] = job.archive
      end
    end
  end
end
