class WorkerJob < BaseJob

  attr_reader :parent_id, :job_type

  def initialize(id, parent_id)
    super(id)
    @parent_id = parent_id
    @complexity = :worker
  end

  def ready_to_mark_as_done?
    @control && @control.done?
  end

  def status_report
    @control.status
  end

end