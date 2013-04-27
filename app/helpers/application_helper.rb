module ApplicationHelper
  def title
    base_title = "Joint Ink"
    title = truncate(@title, :length => 60, :separator => ' ', :omission => '...')
    if @title.nil?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

  def description
    @description.nil? ? "Joint Ink is a new type of publishing platform." : truncate(@description, :length => 150, :separator => ' ', :omission => '...')
  end

  def site_host
    case Rails.env
      when 'development'
        'localhost'
      when 'staging'
        'foobar-staging.herokuapp.com'
      when 'production'
        'jointink.com'
    end
  end

  def span_first_word(text)
    firstWord = text.split(' ').first
    text.sub(firstWord, "<strong>#{firstWord}</strong>")
  end

  def update_image_options(options)
    if cookies[:clientInfo]
      begin
        clientInfo = JSON.parse(cookies[:clientInfo])
      rescue
        return
      end

      # resize the image if we're on small screens
      max_dimension = clientInfo['device_screen_width'] > clientInfo['device_screen_height'] ? clientInfo['device_screen_width'] : clientInfo['device_screen_height']
      if options[:width] && max_dimension < options[:width]
        original_width = options[:width]
        options[:width] = max_dimension
        if options[:height]
          ratio = original_width / options[:height]
          options[:height] = original_width / ratio
        end
      end

      if clientInfo['device_pixel_ratio_rounded'] > 1 && clientInfo['connection_test_result'] == 'networkSuccess' && clientInfo['bandwith'] == 'high'
        options[:width] *= 2 if options[:width]
        options[:height] *= 2 if options[:height]
      end
    end
  end

  def common_js
    script = "
    <!-- JQUERY -->
    <script src='//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'></script>
    <script>window.jQuery || document.write('<script src=\"/offline/javascripts/jquery1.9.js\"><\\/script>')</script>
    "

    if Rails.env == 'production'
      # segment.io
      script += "var analytics=analytics||[];analytics.load=function(e){var t=document.createElement('script');t.type='text/javascript',t.async=!0,t.src=('https:'===document.location.protocol?'https://':'http://')+'d2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/'+e+'/analytics.min.js';var n=document.getElementsByTagName('script')[0];n.parentNode.insertBefore(t,n);var r=function(e){return function(){analytics.push([e].concat(Array.prototype.slice.call(arguments,0)))}},i=['identify','track','trackLink','trackForm','trackClick','trackSubmit','pageview','ab','alias','ready'];for(var s=0;s<i.length;s++)analytics[i[s]]=r(i[s])};
                 analytics.load('zioyk6zfq7');"
    elsif Rails.env == 'development'
      # segment.io
      script += "<script>var analytics=analytics||[];analytics.load=function(e){var t=document.createElement('script');t.type='text/javascript',t.async=!0,t.src=('https:'===document.location.protocol?'https://':'http://')+'d2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/'+e+'/analytics.min.js';var n=document.getElementsByTagName('script')[0];n.parentNode.insertBefore(t,n);var r=function(e){return function(){analytics.push([e].concat(Array.prototype.slice.call(arguments,0)))}},i=['identify','track','trackLink','trackForm','trackClick','trackSubmit','pageview','ab','alias','ready'];for(var s=0;s<i.length;s++)analytics[i[s]]=r(i[s])};
                 analytics.load('qlnuv1pca2');</script>"
    end

    if current_user
      script += "<script>analytics.identify(#{ current_user.id }, #{current_user.analytics_data.to_json.gsub('"', "'")})</script>"
    end

    script
  end

  def time_ago(datetime)
    "<span class='timeago' title='#{datetime}'>#{datetime.strftime("%B %d, %Y")}</span>".html_safe
  end

  def sim_format(string)
    simple_format(string).gsub("<p>", "").gsub("</p>", "").html_safe
  end

  # helper to generate channel/user cover photo URLs
  def cover_photo_path(target, options={})
    update_image_options(options)

    if target.cover_photo.present?
      cl_image_path(target.cover_photo, options)
    end
  end

  # options for the master nav on the homepage
  def home_mast_nav_options
    options = {
        :name => 'Joint Ink',
        :subheader => 'Yeehaw'
    }

    options
  end

end
