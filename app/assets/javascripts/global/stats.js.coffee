jQuery ->

  sendStatRequest = (type) ->
    page_data = $('#analytics-data').data('d')
    data = {
      type: type
      referrer: document.referrer
    }
    if page_data.channelId
      data.channel_id = page_data.channelId
    if page_data.postId
      data.post_id = page_data.postId

    $.ajax
      url: '/stats'
      type: 'POST'
      dataType: 'JSON'
      data: data

  $('.posts-c.posts-show, .users-c.users-show, .channels-c.channels-show').livequery ->
    sendStatRequest('Page View')

  $('.post-show--text').livequery ->
    return if $('#post-editor').length > 0

    clearedTime = false
    clearedScroll = false
    words = $.trim($('.post-show__body').text()).split(' ').length
    console.log(words + " words")
    setTimeout ->
      if $('.post-show--text').length
        if $(window).height() >= $(".post-show__body").height()
          sendReadRequest()
        else
          clearedTime = true
          sendReadRequest() if clearedScroll
    , (Math.max(words * 100, 10000))

    $(window).scroll ->
      if !clearedScroll && $(".post-show__body").offset().top + $(".post-show__body").height() <= $(window).scrollTop() + $(window).height()
        if clearedTime
          clearedScroll = true
          sendReadRequest()

  sendReadRequest = ->
    console.log 'Track Read'
    $('.recommend').trigger('tooltip-show')
    analytics.track('Post Read', $('#analytics-data').data('d'))
    sendStatRequest('Read')