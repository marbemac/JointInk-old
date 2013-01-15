module UserHelper

  def user_avatar(user, options)
    if user.avatar.present?
      cl_image_tag(user.avatar_image, options)
    else
      options.delete(:gravity)
      gravatar_profile_image_tag(user.email, options.merge(:default_image => :mm)).gsub('jpg', 'png').html_safe
    end
  end

  def user_avatar_path(user, options, dpi='1x')

    if dpi == '2x'
      options[:width] *= 2 if options[:width]
      options[:height] *= 2 if options[:height]
    end

    if user.avatar.present?
      cl_image_path(user.avatar_image, options)
    else
      options.delete(:gravity)
      cl_image_path(Digest::MD5.hexdigest(user.email.strip.downcase), {:default_image => :mm, :type=>:gravatar, :format=>:png}.merge(options))
    end
  end

end
