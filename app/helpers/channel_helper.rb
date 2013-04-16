module ChannelHelper

  def channel_photo_path(channel, options={})
    update_image_options(options)
    target = channel.photo_image
    if options[:format]
      target = target.split('.')[0..-2].join('')
    end
    cl_image_path(target, options)
  end

  def channel_mast_nav_options(channel)
    options = {
        :name => channel.name,
        :page_nav => 'channels/mast_nav_section'
    }

    options[:subheader] = channel.description

    if channel.photo.present?
      options[:badge_url] = channel_photo_path(channel, :width => 125, :height => 125, :crop => :thumb, :radius => '1000', :border => {:width => 3, :color => '#333'})
    end

    if channel.cover_photo.present?
      options[:cover_photo_url] = cover_photo_path(channel, :width => 450, :crop => :limit)
    end

    options
  end

end
