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

    options[:badge_url] = user.avatar_id if user.avatar.present?
    options[:cover_photo_id] = user.cover_photo_id if user.cover_photo.present?

    unless user.social_links.empty?
      options[:social_links] = 'users/page_nav_social_links'
    end

    options
  end

  def user_pretty_url(user, target_url=nil)
    if user.domain
      if target_url
        url = "http://#{user.domain}#{send("#{target_url}_path")}"
      else
        url = "http://#{user.domain}"
      end
    else
      if target_url
        url = send("#{target_url}_url", :subdomain => user.username.downcase).chomp('/')
      else
        url = user_url(:subdomain => user.username.downcase).chomp('/')
      end
    end
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
