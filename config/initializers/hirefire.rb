HireFire::Resource.configure do |config|
  #config.dyno(:worker) do
  #  HireFire::Macro::Sidekiq.queue # to return job count for all queues
  #end

  #config.dyno(:mailer) do
  #  HireFire::Macro::Sidekiq.queue(:mailer) # to return the job count for only the mailer queue
  #end
end