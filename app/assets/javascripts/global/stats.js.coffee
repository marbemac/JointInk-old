jQuery ->

  $('.posts-c.text').livequery ->
    clearedTime = false
    clearedScroll = false
    words = $.trim($('#post-body').text()).split(' ').length
    console.log(words + " words")
    setTimeout ->
      if $('.posts-c.text').length
        if $(window).height() >= $("#post-body").height()
          sendRequest()
        else
          clearedTime = true
          sendRequest() if clearedScroll
    , (Math.max(words * 100, 5000))

    $(window).scroll ->
      if !clearedScroll && $("#post-body").offset().top + $("#post-body").height() <= $(window).scrollTop() + $(window).height()
        clearedScroll = true
        sendRequest() if clearedTime

    $('.posts-c.text').trigger('start-stat')

  sendRequest = ->
    $('.recommend').tooltip('show')
    $.post "#{$('#post-data').data('d').url}/read_post"