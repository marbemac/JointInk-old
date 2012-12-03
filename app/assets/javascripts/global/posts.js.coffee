jQuery ->

  # go back in browser history when user clicks escape on post show page
  $(document).on 'keyup', (e) ->
    if (e.keyCode == 27 && $('.post-full').length > 0)
      history.back();