jQuery ->

  $('#channel_photo').change (e) ->
    if (@.files && @.files[0])
      reader = new FileReader()
      reader.onload = (e) ->
        $('#channel_form .fileinput-button img').attr('src', e.target.result)

      reader.readAsDataURL(@.files[0])

  $('#channel_form .permissions .option').click (e) ->
    $('#channel_form .permissions .option').toggleClass('on')
    $('#channel_privacy').val($('#channel_form .permissions .option.on').data('value'))