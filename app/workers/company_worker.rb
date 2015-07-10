class CompanyWorker
  include Sidekiq::Worker

  def perform hash_job
    @company = Company.new hash_job
    @company.save
  end
end
