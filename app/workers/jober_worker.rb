class JoberWorker
  include Sidekiq::Worker

  def perform hash_job
    @job = Job.new hash_job
    @job.save
  end
end
