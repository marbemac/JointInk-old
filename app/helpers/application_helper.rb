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
    @description.nil? ? "ThisThat organizes social media around real-world topics." : truncate(@description, :length => 150, :separator => ' ', :omission => '...')
  end

  def site_host
    case Rails.env
      when 'development'
        'localhost'
      when 'staging'
        'foobar-staging.herokuapp.com'
      when 'production'
        'foobar-staging.herokuapp.com'
    end
  end

  def markdown(text)
    return '' unless text && !text.blank?
    options = {:hard_wrap => true, :filter_html => true, :autolink => true, :no_intraemphasis => true, :fenced_code => true, :gh_blockcode => true}
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(text).html_safe
  end

  def woopra_js
    extra = ""
    if signed_in?
      extra += "tracker.addVisitorProperty('email','#{current_user.email}');"
      if current_user.name
        extra += "tracker.addVisitorProperty('name','#{current_user.name}');"
      else
        extra += "tracker.addVisitorProperty('name','#{current_user.username}');"
      end
    end

    "
    function woopraReady(tracker) {
        tracker.setDomain('getthisthat.com');
        tracker.setIdleTimeout(300000);
        #{extra}
        tracker.track();
        return false;
    }
    (function() {
    var wsc = document.createElement('script');
    wsc.src = document.location.protocol+'//static.woopra.com/js/woopra.js';
    wsc.type = 'text/javascript';
    wsc.async = true;
    var ssc = document.getElementsByTagName('script')[0];
    ssc.parentNode.insertBefore(wsc, ssc);
    })();
    "
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

  def time_ago(datetime)
    "<span class='timeago' title='#{datetime}'>#{datetime.strftime("%B %d, %Y")}</span>".html_safe
  end
end
