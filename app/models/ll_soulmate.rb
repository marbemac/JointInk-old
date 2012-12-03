class LlSoulmate

  class << self

    include Rails.application.routes.url_helpers
    include SoulmateHelper

    def create_topic(topic)
      Soulmate::Loader.new("topic").add(topic_nugget(topic))
    end

    def destroy_topic(topic_id)
      Soulmate::Loader.new("topic").remove({'id' => topic_id})
    end

    def create_user(user)
      if user.status == 'active'
        Soulmate::Loader.new("user").add(user_nugget(user))
      end
    end

    def destroy_user(user_id)
      Soulmate::Loader.new("user").remove({'id' => user_id})
    end
  end
end