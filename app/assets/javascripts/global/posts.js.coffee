jQuery ->

  # go back in browser history when user clicks escape on post show page
  $(document).on 'keyup', (e) ->
    if (e.keyCode == 27 && $('.post-full').length > 0)
      history.back();

  $('body').on 'click', '.recommend.button', (e) ->
    return unless window.authenticate_user()

    self = $(@)

    return if self.hasClass('disabled')

    $.ajax
      url: self.data('url')
      type: if self.hasClass('action') then 'PUT' else 'DELETE'
      beforeSend: (jqXHR, settings) ->
        self.addClass('disabled')
        self.data('old-text', self.text())
        self.text('Recommending')
      complete: (jqXHR, textStatus) ->
        self.removeClass('disabled')
      error: (jqXHR, textStatus, errorThrown) ->
        self.text(self.data('old-text'))
      success: (data, textStatus, jqXHR) ->
        if self.hasClass('action')
          self.text('Recommended')
        else
          self.text('Recommend')

        self.toggleClass('action gray')