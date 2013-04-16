jQuery ->

  $('.blog-post-link i').click (e) ->
    text = $(e.target).siblings("a").text()
    link = "<a href=\"#{text}\">#{text}</a>"
    $('.message .recent-post').html(", and I really liked this: #{link}")