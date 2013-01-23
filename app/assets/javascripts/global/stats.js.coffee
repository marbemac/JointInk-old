jQuery ->
  if $('#post-body').length
    clearedTime = false
    clearedScroll = false
    words = $('#post-body').text().split(' ').length
    console.log(words + " words")
    setTimeout ->
      if $(window).height() >= $("#post-body").height()
        sendRequest()
      else
        clearedTime = true
        sendRequest() if clearedScroll
    , (words * 10)

    $(window).scroll ->
      if !clearedScroll && $("#post-body").offset().top + $("#post-body").height() <= $(window).scrollTop() + $(window).height()
        clearedScroll = true
        sendRequest() if clearedTime


  sendRequest = ->
    $.post "/p/#{$('#post-id').data('post-id')}/read_post"