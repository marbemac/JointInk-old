module PostHelper

  def post_photo_path(post, options)
    update_image_options(options)
    if post.photo.present?
      cl_image_path(post.photo_image, options)
    else
      nil
    end
  end

end
