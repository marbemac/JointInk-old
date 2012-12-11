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
    $('#loader').hide()

  # Initiate timeago timestamps
  $(".timeago").livequery ->
    $(@).timeago()

  # copy input to area
  $('.copy_over').live 'keyup', (e) ->
    $($(@).data('target')).text($(@).val())

  # toggle target element
  $('.toggler').live 'click', (e) ->
    $($(@).data('target')).toggle()