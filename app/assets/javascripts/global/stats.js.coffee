jQuery ->

  $('.post-full.text:not(.editing)').livequery ->
    clearedTime = false
    clearedScroll = false
    words = $.trim($('.post-full-body').text()).split(' ').length
    console.log(words + " words")
    setTimeout ->
      if $('.post-full.text').length
        if $(window).height() >= $(".post-full-body").height()
          sendRequest()
        else
          clearedTime = true
          sendRequest() if clearedScroll
    , (Math.max(words * 100, 10000))

    $(window).scroll ->
      if !clearedScroll && $(".post-full-body").offset().top + $(".post-full-body").height() <= $(window).scrollTop() + $(window).height()
        clearedScroll = true
        sendRequest() if clearedTime

    $('.post-full.text').trigger('start-stat')

  sendRequest = ->
    $('.recommend').trigger('tooltip-show')
#    $.post "#{$('#post-data').data('d').url}/read_post"
    analytics.track('Post Read',$('#analytics-data').data('d'))