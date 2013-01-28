jQuery ->

  # go back in browser history when user clicks escape on post show page
  $(document).on 'keyup', (e) ->
    if (e.keyCode == 27 && $('.post-full').length > 0)
      history.back();

  # recommend buttons
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


  # full page article cover photo sizing and handling
  updateFullPageArticle = ->
    $('#picture-wrapper').height($(window).height())
    $('.white-wrap').css('margin-top', $(window).height())

  $('#posts-show.text.full-page,#posts-edit.text.full-page').livequery ->
    picture = $('#picture-wrapper')
    content = $('.white-wrap')

    updateFullPageArticle()

    setTimeout ->
      $('#post-picture-title').fadeIn(800)
    , 500

    setTimeout ->
      if $(document).scrollTop() <= 60
        $.scrollTo '150',
          duration: 1500
          easing:'easeInOutCubic'
    , 1500

    $(window).on 'scroll', ->
      unless $('#posts-show.text.full-page,#posts-edit.text.full-page').length > 0
        $(window).off 'scroll'
        return

      distance = content.offset().top - $(document).scrollTop()
      height = $(window).height()
      $('#picture-wrapper').css(opacity: distance / height)

    $(window).on 'resize', ->
      $('body').stopTime 'resize-full-page'
      $('body').oneTime 200, 'resize-full-page', ->
        unless $('#posts-show.text.full-page,#posts-edit.text.full-page').length > 0
          $(window).off 'resize'
          return
        updateFullPageArticle()

  # post audio
  $('body').bind 'reset-audio-player', ->
    if $("#jquery_jplayer_1").data('url')
      url = $("#jquery_jplayer_1").data('url')
      extension = _.last(url.split('.'))
      media = {}
      media[extension] = url
      console.log "Loading #{url} #{extension} audio."

      vol = 0.2
      volChanged = false

      $("#jquery_jplayer_1").jPlayer("destroy").jPlayer
        ready: ->
          $(@).jPlayer("setMedia", media).jPlayer("play")
        swfPath: "/assets/javascripts"
        supplied: extension
        timeupdate: (event) ->
          x =  event.jPlayer.status.currentTime
          d = event.jPlayer.status.duration
          v = event.jPlayer.status.volume
          if x < 5
            $(@).jPlayer("volume", vol/5 * x)
          else if d - x < 6
            $(@).jPlayer("volume", vol/5 * (d-x))
          else if (!volChanged)
            $(@).jPlayer("volume", vol)
        volumeChange: (event) ->
          volChanged = true;
          vol = event.jPlayer.status.volume
      $("#jp_container_1").show()
    else
      $("#jp_container_1").hide()

  $("#jquery_jplayer_1").livequery ->
    $('body').trigger('reset-audio-player')

  # scroll pictures slowly
  $(".posts-c.picture").livequery ->
    setTimeout ->
      $.scrollTo 'max',
        duration: 3000
        easing: 'easeInOutCubic'
    , 1000