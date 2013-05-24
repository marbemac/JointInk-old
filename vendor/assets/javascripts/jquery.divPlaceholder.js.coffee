jQuery ->

    updateDivPlaceholder = (target) ->
      if target.textContent
        target.removeAttribute 'data-div-placeholder-show'
      else
        target.setAttribute 'data-div-placeholder-show', 'true'

    for placeholder in $('*[data-placeholder]')
      updateDivPlaceholder(placeholder)

    $(document).on 'change keydown keypress input', '*[data-placeholder]', ->
      updateDivPlaceholder(@)