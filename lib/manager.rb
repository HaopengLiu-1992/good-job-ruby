require_relative '../lib/role/worker/worker'
require_relative '../lib/role/admin/admin'
require_relative 'web/api'
require_relative 'logging'

require 'thread'

module GoodJob
  class Manager
    include Logging

    def initialize(_settings = {})
      admin_enabled = ENV.fetch('ADMIN', '').upcase == 'TRUE'
      worker_enabled = ENV.fetch('WORKER', '').upcase == 'TRUE'
      if admin_enabled
        @admin = Role::Admin.new
        @admin.start
      end

      if worker_enabled
        @worker = Role::Worker.new
        @worker.start
      end

      @mutex = Mutex.new
      @cond_var = ConditionVariable.new
      @quit = false
    end

    at_exit do
      logger.info "Force quit!"
      @quit = true
      @admin&.stop
      @worker&.stop
    end

    def run
      start_api if @admin
      if @worker
        loop do
          sleep 1 until gets.chomp == "exit"
        end
      end
    end

    def start_api
      API.set :manager, self
      API.set :bind, 'localhost'
      API.set :port, 5000
      API.run!
    end

    def get_job_status(job_id)
      @admin.get_job_status(job_id)
    end

    def get_all_jobs
      @admin.report_job_status
    end

    def get_worker_status
      @admin.get_workers_status
    end

    def start_job(job)
      @admin.execute(job)
    end

    def cancel_job(job_id)
      @admin.cancel_job(job_id)
    end
  end
end
