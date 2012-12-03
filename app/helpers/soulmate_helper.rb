module SoulmateHelper
  include Rails.application.routes.url_helpers

  def user_nugget(user)
    nugget = {
              'id' => user.id,
              'term' => user.username,
              'data' => {
                      'slug' => user.slug,
                      'url' => user_path(user)
              }
    }

    if user.name && !user.name.blank?
      nugget['data']['name'] = user.name
      nugget['aliases'] = [user.name]
    end

    nugget
  end

  def topic_nugget(topic)
    nugget = {
              'id' => topic.id,
              'term' => topic.name,
              'data' => {
                      'slug' => topic.slug,
                      'url' => topic_path(topic)
              }
    }

    nugget
  end
end