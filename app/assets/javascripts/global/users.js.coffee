jQuery ->

  $('body').on "click", ".ji-form__plus", (e) ->
    line = $(@).prev().clone()
    return if $.trim(line.val()).length == 0
    line.val('')
    $(@).before(line)