jQuery ->

  $('#users-settings').on "click", ".more-social", (e) ->
  self = e.target
  new_line = $(self).closest('form').find('.line').first().clone()
  new_line.find('input').val('')
  new_line.insertBefore(self)
  new_line.find('.name').remove()