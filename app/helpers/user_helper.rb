module UserHelper

  def user_avatar(user, options)
    if user.avatar.present?
      cl_image_tag(user.avatar_image, options)
    else
      options.delete(:gravity)
      gravatar_profile_image_tag(user.email, options.merge(:default_image => :mm)).gsub('jpg', 'png').html_safe
    end
  end

  def user_avatar_path(user, options)
    update_image_options(options)

    if user.avatar.present?
      cl_image_path(user.avatar_image, options)
    else
      options.delete(:gravity)
      cl_image_path(Digest::MD5.hexdigest(user.email.strip.downcase), {:default_image => :mm, :type=>:gravatar, :format=>:png}.merge(options))
    end
  end

  def user_page_nav_options(user)
    options = {
        :name => user.name,
        :page_nav => 'users/page_nav_links'
    }

    if user.bio && !user.bio.blank?
      options[:subheader] = user.bio
    end

    if user.avatar.present?
      options[:badge_url] = user_avatar_path(user, :width => 250, :height => 250, :crop => :thumb, :gravity => :face)
    else
      hash = Digest::MD5.hexdigest(user.email.downcase)
      options[:badge_url] = "http://www.gravatar.com/avatar/#{hash}?s=250&d=mm"
    end

    if user.cover_photo.present?
      options[:cover_photo_url] = cover_photo_path(user, :width => 450, :crop => :limit)
    end

    unless user.social_links.empty?
      options[:social_links] = 'users/page_nav_social_links'
    end

    options
  end

  def user_social_icon(link)
    match = /facebook|twitter|linkedin|pinterest|google|github|@/.match(link)
    if %w(facebook twitter linkedin pinterest).include? match.to_s
      "icon-#{match.to_s}-sign"
    elsif match.to_s == "google"
      "icon-google-plus-sign"
    elsif match.to_s == "github"
      "icon-github"
    elsif match.to_s == "@"
      "icon-envelope-alt"
    else
      "icon-external-link"
    end
  end

end
