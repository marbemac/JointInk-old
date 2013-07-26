module ChannelHelper

  def channel_photo_path(channel, options={})
    target = channel.cover_photo
    if options[:format]
      target = target.split('.')[0..-2].join('')
    end
    cl_image_path(target, options)
  end

  def channel_page_nav_options(channel)
    options = {
        :name => channel.name,
        :page_nav => 'channels/page_nav_links'
    }

    options[:subheader] = channel.description

    if channel.cover_photo.present?
      options[:cover_photo_id] = channel.photo_id
    end

    options
  end

end
