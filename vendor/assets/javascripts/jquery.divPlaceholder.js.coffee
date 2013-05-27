jQuery ->

    updateDivPlaceholder = (target) ->
      if $.trim(target.textContent)
        target.removeAttribute 'data-div-placeholder-show'
      else
        target.setAttribute 'data-div-placeholder-show', 'true'

    $('*[data-placeholder]').livequery ->
      updateDivPlaceholder(@)

    $(document).on 'change keydown keypress input', '*[data-placeholder]', ->
      updateDivPlaceholder(@)