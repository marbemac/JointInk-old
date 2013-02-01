jQuery ->
  $.support.backgroundSize = false;
  $.each ['backgroundSize','MozBackgroundSize','WebkitbackgroundSize','ObackgroundSize'], ->
    if document.body.style[this] != undefined
      $.support.backgroundSize = true

  $.support.placeholder = ->
    i = document.createElement('input')
    i.placeholder != undefined

  Modernizr.load(
    [
      {
        test: $.support.placeholder()
        nope : '/assets/javascripts/jquery.placeholder.shiv.js'
        complete : ->
          if window.Placeholders
            $('input, textarea').placeholder()
      }
      {
        test: $.support.backgroundSize
        nope : '/assets/javascripts/jquery.background.shiv.js'
        complete : ->
          unless $.support.backgroundSize
            $('.cover-image').css( "background-size", "cover" );
            $('.contain-image').css( "background-size", "contain" );
      }
    ]
  )