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
    #<!-- Facebook -->
    #<div id='fb-root'></div>
    #<script>
    #  window.fbAsyncInit = function() {
    #    // init the FB JS SDK
    #FB.init({
    #            appId      : '468940663116634', // App ID from the App Dashboard
    #channelUrl : '//www.getthisthat.com/channel.html', // Channel File for x-domain communication
    #status     : true, // check the login status upon init?
    #cookie     : true, // set sessions cookies to allow your server to access the session?
    #xfbml      : true  // parse XFBML tags on this page?
    #    });
    #
    #    // Additional initialization code such as adding Event Listeners goes here
    #
    #};
    #
    #// Load the SDK's source Asynchronously
    #  // Note that the debug version is being actively developed and might
    #  // contain some type checks that are overly strict.
    #  // Please report such bugs using the bugs tool.
    #  (function(d, debug){
    #     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
    #     if (d.getElementById(id)) {return;}
    #     js = d.createElement('script'); js.id = id; js.async = true;
    #     js.src = '//connect.facebook.net/en_US/all.js';
    #     ref.parentNode.insertBefore(js, ref);
    #   }(document, /*debug*/ false));
    #</script>
    #
    #<!-- Twitter -->
    #<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='//platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','twitter-wjs');</script>

    script = "
    <!-- JQUERY -->
    <script src='http://code.jquery.com/jquery-1.9.0.js'></script>
    <script src='http://code.jquery.com/jquery-migrate-1.0.0.js'></script>
    <script>window.jQuery || document.write('<script src=\"/offline/javascripts/jquery1.9.js\"><\\/script>')</script>
    "

    if Rails.env == 'production'
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
    end

    script
  end

  def google_analytics
    "

    "
  end

  def time_ago(datetime)
    "<span class='timeago' title='#{datetime}'>#{datetime.strftime("%B %d, %Y")}</span>".html_safe
  end
end
