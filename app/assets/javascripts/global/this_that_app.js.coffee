jQuery ->

  # pjax
  $('#data-pjax-container').pjax 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])',
    timeout: 5000
  .on 'pjax:start', ->
    $('body').oneTime 1000, 'show-loader', ->
      $('#loader').fadeIn(200)
  .on 'pjax:end', ->
    $('body').stopTime 'show-loader'
    $('#loader').hide()

  # Initiate timeago timestamps
#  $(".timeago").livequery ->
#    $(@).timeago()

  # copy input to area
  $('body').on 'keyup', '.copy-over', (e) ->
    $($(@).data('target')).text($(@).text())

  # toggle target element
  $('.toggler').live 'click', (e) ->
    $($(@).data('target')).toggle()

  # tooltips
  $('.has-tooltip').livequery ->
    $(@).tooltip()