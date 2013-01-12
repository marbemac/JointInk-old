module ChannelHelper

  def channel_photo_path(channel, options)
    path = channel.photo_image
    parts = path.split('.')
    path = path.gsub(parts.last, 'png')
    cl_image_path(path, options)
  end

end
