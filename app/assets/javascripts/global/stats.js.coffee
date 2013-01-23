jQuery ->
  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() == $(document).height()
