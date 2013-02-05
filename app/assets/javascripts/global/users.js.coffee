jQuery ->
  $('#colorSelector').ColorPicker
#    color: $('#colorSelector div').css('backgroundColor')
    onShow: (colpkr) ->
      $(colpkr).fadeIn(500)
      false
    onHide: (colpkr) ->
      $(colpkr).fadeOut(500)
      false
    onChange: (hsb, hex, rgb) ->
      $('#colorSelector div').css('backgroundColor', "##{hex}")
      $('#user_theme_header_color').val("##{hex}")

  $('#patternSelector .prev').click (e) ->
    parent = $(@).parent()
    patterns = parent.data('patterns')
    index = parent.data('current-index')
    next = patterns[index-1]
    unless next
      next = patterns[patterns.length - 1]
      index = patterns.length
    parent.data('current-index', index-1)
    current = parent.css('background-image').replace('url','').replace('(','').replace('"','').replace(')','').split('/')
    current[current.length - 1] = next
    parent.attr('style', "background: url('#{current.join('/')}');")
    $("#user_theme_background_pattern").val(next)

  $('#patternSelector .next').click (e) ->
    parent = $(@).parent()
    patterns = parent.data('patterns')
    index = parent.data('current-index')
    next = patterns[index+1]
    unless next
      next = patterns[0]
      index = -1
    parent.data('current-index', index+1)
    current = parent.css('background-image').replace('url','').replace('(','').replace('"','').replace(')','').split('/')
    current[current.length - 1] = next
    parent.attr('style', "background: url('#{current.join('/')}');")
    $("#user_theme_background_pattern").val(next)