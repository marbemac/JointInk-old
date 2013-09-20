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
        'joint-ink.com'
    end
  end

  def span_first_word(text)
    firstWord = text.split(' ').first
    text.sub(firstWord, "<strong>#{firstWord}</strong>")
  end

  def page_analytics_data
    data = {}
    @page_entities.each do |entity_data|
      data.merge!(entity_data['entity'].analytics_data(entity_data['name']))
    end
    data
  end

  def common_js
    script = "
    <script src='//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js'></script>

    <!-- JQUERY -->
    <script src='//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'></script>
    <script>window.jQuery || document.write('<script src=\"/offline/javascripts/jquery1.9.js\"><\\/script>')</script>
    "

    if Rails.env == 'production'
      # segment.io
      script += "<script>var analytics=analytics||[];analytics.load=function(e){var t=document.createElement('script');t.type='text/javascript',t.async=!0,t.src=('https:'===document.location.protocol?'https://':'http://')+'d2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/'+e+'/analytics.min.js';var n=document.getElementsByTagName('script')[0];n.parentNode.insertBefore(t,n);var r=function(e){return function(){analytics.push([e].concat(Array.prototype.slice.call(arguments,0)))}},i=['identify','track','trackLink','trackForm','trackClick','trackSubmit','pageview','ab','alias','ready'];for(var s=0;s<i.length;s++)analytics[i[s]]=r(i[s])};
                 analytics.load('zioyk6zfq7');</script>"
    elsif Rails.env == 'development'
      # segment.io
      script += "<script>var analytics=analytics||[];analytics.load=function(e){var t=document.createElement('script');t.type='text/javascript',t.async=!0,t.src=('https:'===document.location.protocol?'https://':'http://')+'d2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/'+e+'/analytics.min.js';var n=document.getElementsByTagName('script')[0];n.parentNode.insertBefore(t,n);var r=function(e){return function(){analytics.push([e].concat(Array.prototype.slice.call(arguments,0)))}},i=['identify','track','trackLink','trackForm','trackClick','trackSubmit','pageview','ab','alias','ready'];for(var s=0;s<i.length;s++)analytics[i[s]]=r(i[s])};
                 analytics.load('qlnuv1pca2');</script>"
    end

    script
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

  def number_direction(number)
    return 'neutral' if !number || number == 0
    if number.to_i > 0
      'positive'
    elsif number.to_i < 0
      'negative'
    end
  end

  def number_symbol(number)
    return '' if !number || number == 0
    if number.to_i > 0
      '+'
    elsif number.to_i < 0
      ''
    end
  end

  def prepend_absolute_js_url(tag)
    tag.gsub('src="', 'src="'+JointInk::Application.config.app_url)
  end

  def prepend_absolute_css_url(tag)
    tag.gsub('href="', 'href="'+JointInk::Application.config.app_url)
  end


end
