module ChannelHelper

  def channel_photo_path(channel, options, dpi='1x')
    if dpi == '2x'
      options[:width] *= 2 if options[:width]
      options[:height] *= 2 if options[:height]
    end

    cl_image_path(channel.photo_image, options)
  end

end
