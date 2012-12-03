class SmDestroyUser

  @queue = :fast

  def self.perform(user_id)
    LlSoulmate.destroy_user(user_id)
  end
end