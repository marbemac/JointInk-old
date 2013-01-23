module ChannelHelper

  def channel_photo_path(channel, options)
    update_image_options(options)
    cl_image_path(channel.photo_image, options)
  end

end
