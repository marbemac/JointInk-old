jQuery ->

  $('.post-show--text').livequery ->
    return if $('#post-editor').length > 0

    clearedTime = false
    clearedScroll = false
    words = $.trim($('.post-show__body').text()).split(' ').length
    console.log(words + " words")
    setTimeout ->
      if $('.post-full.text').length
        if $(window).height() >= $(".post-show__body").height()
          sendRequest()
        else
          clearedTime = true
          sendRequest() if clearedScroll
    , (Math.max(words * 100, 10000))

    $(window).scroll ->
      if !clearedScroll && $(".post-show__body").offset().top + $(".post-show__body").height() <= $(window).scrollTop() + $(window).height()
        clearedScroll = true
        sendRequest() if clearedTime

    $('.post-show--text').trigger('start-stat')

  sendRequest = ->
    $('.recommend').trigger('tooltip-show')
    analytics.track('Post Read',$('#analytics-data').data('d'))