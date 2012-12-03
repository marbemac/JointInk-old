jQuery ->

  # pjax
  $('#data-pjax-container').pjax 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])',
    timeout: 5000
  .on 'pjax:start', ->
    $('body').oneTime 1000, 'show-loader', ->
      $('#loader').fadeIn(200)
  .on 'pjax:end', ->
    set_sidebar_height()
    $('body').stopTime 'show-loader'

  # Initiate timeago timestamps
  $(".timeago").livequery ->
    $(@).timeago()

  # Left sidebar height adjustment
  set_sidebar_height = ->
    window_height = $(window).height()
    sidebar = $("#sidebar")
    if sidebar.height() < window_height
      sidebar.css('position': 'fixed')
    else
      sidebar.css('position': 'static')

  set_sidebar_height()
  $(window).resize ->
    set_sidebar_height()
  # end left sidebar

  # copy input to area
  $('.copy_over').live 'keyup', (e) ->
    $($(@).data('target')).text($(@).val())

  # toggle target element
  $('.toggler').live 'click', (e) ->
    $($(@).data('target')).toggle()