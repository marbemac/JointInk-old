jQuery ->

  # pjax
  $('#data-pjax-container').pjax 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])',
    timeout: 5000
  .on 'pjax:start', ->
    # unbind the read stat tracking
    $(window).unbind('scroll')

    $('body').oneTime 1000, 'show-loader', ->
      $('#loader').fadeIn(200)
  .on 'pjax:end', ->
    analytics.pageview();  # Analytics.js
    $('body').stopTime 'show-loader'
    $('#loader').hide()

  # Initiate timeago timestamps
#  $(".timeago").livequery ->
#    $(@).timeago()

  # copy input to area
  $('body').on 'keyup', '.copy-over', (e) ->
    value = if $(@).is('input') then $(@).val() else $(@).text()
    $($(@).data('target')).text(value)

  # toggle target element
  $('body').on 'click', '.toggler', (e) ->
    $($(@).data('target')).toggle()