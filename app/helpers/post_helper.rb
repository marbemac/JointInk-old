module PostHelper

  def post_photo_path(post, options, dpi='1x')
    if dpi == '2x'
      options[:width] *= 2 if options[:width]
      options[:height] *= 2 if options[:height]
    end

    if post.photo.present?
      cl_image_path(post.photo_image, options)
    else
      nil
    end
  end

end
