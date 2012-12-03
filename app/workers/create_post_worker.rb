class CreatePostWorker
  include Sidekiq::Worker

  def perform(account_id, url, comment, created_at, social_data)
    if account_id
      account = Account.find(account_id)
    else
      account = nil
    end

    Post.create_from_url(account, url, comment, created_at, social_data)
  end
end