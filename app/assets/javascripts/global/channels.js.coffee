jQuery ->

  $('#channel_photo,#user_avatar').change (e) ->
    if (@.files && @.files[0])
      reader = new FileReader()
      reader.onload = (e) ->
        $('#channel_form .fileinput-button img,#settings .fileinput-button img').attr('src', e.target.result)

      reader.readAsDataURL(@.files[0])

  $('#channel_form .permissions .option').click (e) ->
    unless $(@).hasClass('on')
      $('#channel_form .permissions .option').toggleClass('on')
      $('#channel_privacy').val($('#channel_form .permissions .option.on').data('value'))