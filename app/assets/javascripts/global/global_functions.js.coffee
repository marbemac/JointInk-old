jQuery ->

  window.globalSuccess = (data) ->
    if data.flash
      createGrowl false, data.flash, 'Success', 'green'

    if data.redirect
      window.location = data.redirect

  window.globalError = (jqXHR, target=null) ->
    data = $.parseJSON(jqXHR.responseText)

    #    if data.flash
    #      createGrowl false, data.flash, 'Error', 'red'
    switch jqXHR.status
      when 422
        if target && data && data.errors
          target.find('.alert-error').remove()
          errors_container = $('<div/>').addClass('alert alert-error').prepend('<a class="close" data-dismiss="alert">x</a>')
          for key,errors of data.errors
            if errors instanceof Array
              for error in errors
                errors_container.append("<div>#{error}</div>")
            else
              errors_container.append("<div>#{errors}</div>")
          target.find('.errors').show().prepend(errors_container)

  # case insensitive contains selector
  jQuery.expr[':'].Contains = (a, i, m) ->
      return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0