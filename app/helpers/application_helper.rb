module ApplicationHelper
  def title
    base_title = "ThisThat"
    title = truncate(@title, :length => 60, :separator => ' ', :omission => '...')
    if @title.nil?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

  def description
    @description.nil? ? "ThisThat is a new type of publishing platform." : truncate(@description, :length => 150, :separator => ' ', :omission => '...')
  end

  def site_host
    case Rails.env
      when 'development'
        'localhost'
      when 'staging'
        'foobar-staging.herokuapp.com'
      when 'production'
        'www.getthisthat.com'
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
      # google analytics
      script += "
      <script type='text/javascript'>

        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-36765363-1']);
        _gaq.push(['_setDomainName', 'getthisthat.com']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();

      </script>
      "
      # customer.io
      script += "
        <script type='text/javascript'>
          var _cio = _cio || [];
          (function() {
            var a,b,c;a=function(f){return function(){_cio.push([f].
            concat(Array.prototype.slice.call(arguments,0)))}};b=['identify',
            'track'];for(c=0;c<b.length;c++){_cio[b[c]]=a(b[c])};
            var t = document.createElement('script'),
                s = document.getElementsByTagName('script')[0];
            t.async = true;
            t.id    = 'cio-tracker';
            t.setAttribute('data-site-id', 'f7f518502623577ea722');
            t.src = 'https://assets.customer.io/assets/track.js';
            s.parentNode.insertBefore(t, s);
          })();
        </script>
      "
    elsif Rails.env == 'development'
      #customer.io
      script += "
        <script type='text/javascript'>
          var _cio = _cio || [];
          (function() {
            var a,b,c;a=function(f){return function(){_cio.push([f].
            concat(Array.prototype.slice.call(arguments,0)))}};b=['identify',
            'track'];for(c=0;c<b.length;c++){_cio[b[c]]=a(b[c])};
            var t = document.createElement('script'),
                s = document.getElementsByTagName('script')[0];
            t.async = true;
            t.id    = 'cio-tracker';
            t.setAttribute('data-site-id', '04361354fb0b5fe0d1b9');
            t.src = 'https://assets.customer.io/assets/track.js';
            s.parentNode.insertBefore(t, s);
          })();
        </script>
      "
    end

    if current_user
      # add customer.io data
      script += "
        <script type='text/javascript'>
          _cio.identify({
            // Required attributes
            id: 'user_#{current_user.id}',
            email: '#{current_user.email}',
            created_at: #{current_user.created_at.to_i},

            // Optional (these are examples. You can name attributes what you wish)

            username: '#{current_user.username}',
            first_name: '#{current_user.first_name}',
            last_sign_in: '#{current_user.last_sign_in_at.to_i}'
          });
        </script>
      "
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
        :name => 'ThisThat',
        :subheader => 'Yeehaw'
    }

    options
  end

end
