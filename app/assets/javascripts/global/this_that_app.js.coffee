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

  # toggle target element
  $('body').on 'click', '.toggler', (e) ->
    $($(@).data('target')).toggle()

  # prevent page loads when clicking/tapping on links that are on
  $('body').on 'click', '.on a,a.on', (e) ->
    e.preventDefault()
    false