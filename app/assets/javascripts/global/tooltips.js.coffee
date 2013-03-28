jQuery ->

  buildTooltip = ($target) ->
    $themes = ['tip-classic','tip-alert','tip-success']
    $placements = ['tip-top','tip-right','tip-bottom','tip-left']
    $positions = ['tip-absolute','tip-fixed']

    $tooltip = $('.tooltip:first')
    $placement = 'tip-top'
    $theme = 'tip-classic'
    $position = 'tip-absolute'
    $new = false

    unless $tooltip.length
      $new = true
      $tooltip = $('<div/>').addClass("tooltip").html("<div class='tooltip-wrapper'></div><i class='caret'></i>")
      $('body').append($tooltip)

    $tooltip.css('visibility', 'hidden').show()

    $placement = "tip-#{$target.data('placement')}" if $target.data('placement')
    $theme = "tip-#{$target.data('theme')}" if $target.data('theme')
    $position = "tip-#{$target.data('position')}" if $target.data('position')

    if $target.is('[title]')
      $target.data('title', $target.attr('title')).removeAttr('title')

    $title = $target.data('title')
    $tooltip.find('.tooltip-wrapper').html($title)

    if $position == 'tip-absolute'
      $offsetTop = $target.offset().top
    else
      $offsetTop = $target.position().top

    $offsetLeft = $target.offset().left

    switch $placement
      when 'tip-top'
        $iconClass = 'icon-caret-down'
        $offsetTop = $offsetTop - $tooltip.outerHeight() - 10
        $offsetRight = 'auto'
        $offsetLeft = $offsetLeft + ($target.outerWidth()/2) - ($tooltip.outerWidth()/2)

      when 'tip-right'
        $iconClass = 'icon-caret-left'
        $offsetTop = $offsetTop + ($target.outerHeight()/2) - ($tooltip.outerHeight()/2)
        $offsetRight = 'auto'
        $offsetLeft = $offsetLeft + $target.outerWidth() + 10

      when 'tip-bottom'
        $iconClass = 'icon-caret-up'
        $offsetTop = $offsetTop + $target.outerHeight() + 10
        $offsetRight = 'auto'
        $offsetLeft = $offsetLeft + ($target.outerWidth()/2) - ($tooltip.outerWidth()/2)

      when 'tip-left'
        $iconClass = 'icon-caret-right'
        $offsetTop = $offsetTop + ($target.outerHeight()/2) - ($tooltip.outerHeight()/2)
        $offsetRight = $(document).width() - $offsetLeft + 10
        $offsetLeft = 'auto'

    $tooltip.removeClass($themes.join(',')+$placements.join(',')+$positions.join(',')).addClass("#{$position} #{$theme} #{$placement}")
    $tooltip.find('.caret').removeClass('icon-caret-up,icon-caret-right,icon-caret-down,icon-caret-left').addClass($iconClass)

    unless $new
      $tooltip.addClass('transition')

    $tooltip.css({top: $offsetTop, right: $offsetRight, left: $offsetLeft, visibility: 'visible'})

  $('body').on 'mouseenter', '.has-tip:not(.manual-tip)', (e) ->
    buildTooltip($(e.currentTarget))

  $('body').on 'mouseleave', '.has-tip:not(.manual-tip)', (e) ->
    $('.tooltip').hide()

  $('body').on 'tooltip-show', '.has-tip', (e) ->
    buildTooltip($(e.currentTarget))

  $('body').on 'tooltip-hide', '.has-tip', (e) ->
    $('.tooltip').hide()