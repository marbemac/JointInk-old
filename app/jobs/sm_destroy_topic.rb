class SmDestroyTopic

  @queue = :fast

  def self.perform(topic_id)
    LlSoulmate.destroy_topic(topic_id)
  end
end