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
  $(".timeago").livequery ->
    $(@).timeago()

  # copy input to area
  $('.copy-over').live 'keyup', (e) ->
    $($(@).data('target')).text($(@).val())

  # toggle target element
  $('.toggler').live 'click', (e) ->
    $($(@).data('target')).toggle()

  $.cookie("dpi", '2x', { expires : 1 });

  # responsive images
#  for element in $('.ri')
#    value = $(element).css('background-image')
#
#    width = value.match /w_(\d+)/
#    value = value.replace /w_(\d+)/, 'w_' + width[1] * 2
#    height = value.match /h_(\d+)/
#    value = value.replace /h_(\d+)/, 'h_' + height[1] * 2
#
#    $(element).attr('style', "background-image: #{value}")