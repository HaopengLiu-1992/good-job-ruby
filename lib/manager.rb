class Manager
  def initialize
    admin_enabled = ENV.fetch('ADMIN', false)
    worker_enabled = ENV.fetch('WORKER', false)
    @admin = start_admin if admin_enabled
    @worker = start_worker if worker_enabled
  end

  def start_worker

  end

  def start_admin

  end

  def stop_all
    @admin.stop if @admin
    @worker.stop if @worker
  end

  def report_job_status(job_id)

  end

  def get_all_jobs

  end

  def report_admin_status

  end

  def track_worker_status

  end

  def run_job

  end
end
