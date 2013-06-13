jQuery ->

  $('.tt-form input[type="file"]').change (e) ->
    $self = $(@)
    if (@.files && @.files[0])
      reader = new FileReader()
      reader.onload = (e) ->
        $self.parents('.fileinput-button:first').find('img').attr('src', e.target.result)

      reader.readAsDataURL(@.files[0])

  $('#channel_form .permissions .option').click (e) ->
    unless $(@).hasClass('on')
      $('#channel_form .permissions .option').toggleClass('on')
      $('#channel_privacy').val($('#channel_form .permissions .option.on').data('value'))

  $('body').on 'keyup', '.ji-form__item--channel-name input', (e) ->
    return if $('.ji-form__item--channel-email input').is(':disabled')
    $('.ji-form__item--channel-email input').val($.camelCase($.trim($(@).val()).replace(/\s+/g, '-')))