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

  def social_js
    "
    <!-- Facebook -->
    <div id='fb-root'></div>
    <script>(function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = '//connect.facebook.net/en_US/all.js#xfbml=1';
        fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));</script>

    <!-- Twitter -->
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='//platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','twitter-wjs');</script>

    <!-- JQUERY -->
    <script src='//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'></script>
    <script>window.jQuery || document.write('<script src=\"/offline/javascripts/jquery1.8.js\"><\\/script>')</script>
    "
  end

  def google_analytics
    "
    <script type='text/javascript'>

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-36765363-1']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>
    "
  end

  def time_ago(datetime)
    "<span class='timeago' title='#{datetime}'>#{datetime.strftime("%B %d, %Y")}</span>".html_safe
  end
end
