module CloudinaryHelper

  def cloudinary_background_image(cloudinary_id, options={})
    {:class => 'cn-bg-img', 'data-src' => cloudinary_id}.merge(options)
  end

  def cloudinary_image(cloudinary_id, options={})
    {:class => 'cn-img', 'data-src' => cloudinary_id}.merge(options)
  end

end
