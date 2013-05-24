jQuery ->

  $(document).on 'keyup', (e) ->
    keycode = if e.keyCode then e.keyCode else e.which

    # go back in browser history when user clicks escape on post show page
    if keycode == 27 && $('.post-show').length > 0
      history.back();

    if keycode == 37 && $('#prev-post').length > 0
      $('#prev-post').click()

    if keycode == 39 && $('#next-post').length > 0
      $('#next-post').click()

  # swiping posts
  $('body').on 'swiperight', (e) ->
    if $('#prev-post').length > 0
      $('#prev-post').click()
  $('body').on 'swipeleft', (e) ->
    if $('#next-post').length > 0
      $('#next-post').click()

  # next/prev post buttons
  $('body').on 'click', '#next-post,#prev-post', (e) ->
    $(@).fadeTo(0,100).effect 'highlight', {}, 500


  # recommend buttons
  recommendButtonColor = (target) ->
    count = parseInt(target.text())
    if count < 1
      '#2C84AC'
    else if count < 3
      '#28799D'
    else if count < 5
      '#216887'
    else if count < 7
      '#87634E'
    else if count < 10
      '#2C84AC'
    else if count < 15
      '#874C30'
    else
      '#873112'

  $('.recommend').livequery ->
    $(@).find('.count').css('background-color', recommendButtonColor($(@).find('.count')))

  # handle recommends
  $('body').on 'click', '.recommend .button', (e) ->
    self = $(@)

    return if self.hasClass('disabled')

    $.ajax
      url: self.data('url')
      type: if self.hasClass('action') then 'PUT' else 'DELETE'
      dataType: 'json'
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
          analytics.track('Post Recommend', $('#analytics-data').data('d'))
        else
          self.text('Recommend')
          analytics.track('Post Remove Recommend', $('#analytics-data').data('d'))

        self.toggleClass('action gray')

        oldCount = self.parent().find('.count')
        newCount = $('<span/>').addClass('count').text(data.votes_count).css(position:'absolute',top:0,right:0,display:'none','border-bottom':'1px solid #EFEFEF')
        newCount.css('background-color', recommendButtonColor(newCount))
        self.parent().append(newCount)
        newCount.slideDown 500, 'easeOutBounce', ->
          oldCount.remove()
          newCount.css(position:'static','border-bottom':'none')

  # link entire post tile
  $('body').on 'click', '.post-tile__content', (e) ->
    unless $(e.target).is('a,h3')
      target = $(@).find('.js-target-url')
      if window.location.host.toLowerCase().indexOf(target.attr('href').toLowerCase().split('/')[2]) != -1
        console.log 'fee'
        target.click()
      else
        window.location = target.attr('href')

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


  # ADDING and REMOVING channels on post show pages
  # toggle channel autocomplete
  $('#post-channel-autocomplete input').autocomplete
    serviceUrl: '/search/channels'
    minChars: 3
    deferRequestBy: 50
    noCache: false
    appendTo: '.post-show__add-channel .autocomplete'
    position: 'static'
    onSelect: (suggestion) ->
      $.ajax
        url: "#{$('#post-data').data('d').url}/channels"
        type: 'PUT'
        dataType: 'json'
        data: {channel_id: suggestion.data.id}
        success: (data, textStatus, jqXHR) ->
          $('.post-show__channels .content').show().find('ul').append(data.channel.list_item)
          $(window).scrollTop($(document).height());
          $('#post-channel-autocomplete input').val('')

  $('body').on 'click', '.editor-channel-remove', (e) ->
    return if $('#post-editor').length > 0
    e.preventDefault()
    self = $(@)
    $.ajax
      url: $(@).attr('href')
      type: 'DELETE'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        self.parents('li:first').remove()
    false