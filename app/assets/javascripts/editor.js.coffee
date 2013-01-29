jQuery ->

  $('#post-picture-title h1, #post-title, #post-body').attr('contenteditable', true)

  # start the redactor editor
  if $('#post-body').length
    $('#post-body').redactor
#      air: true
#      airButtons: ['formatting','bold','italic','|','unorderedlist','orderedlist','link']
      fixed: true
      fixedBox: true
      fixedTop: 20
      buttons: ['formatting','bold','italic','|','unorderedlist','orderedlist','link']
      allowedTags: ["a", "p", "b", "i", "img", "blockquote", "ul", "ol", "li", "h3", "h4"]
      formattingTags: ['h3','h4','p','blockquote']

  # prompt them before they leave the page, unless they are publishing or discarding
  $(window).bind 'beforeunload', ->
    unless $('.editor-publish,.editor-discard').hasClass('disabled')
      return 'Are you sure you want to leave?'

  # handle photo uploads
  $('#picture-wrapper .fileinput-button input').fileupload
    dataType: "json"
    type: 'PUT'
    add: (e,data) ->
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.submit()
      else
        alert("#{file.name} is not a gif, jpeg, or png image file")
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#picture-wrapper .fileinput-button .loading').text("#{progress}%")
    done: (e,data) ->
      $('#picture-wrapper .fileinput-button .loading').text('')
      $('#picture-wrapper .image').css('background-image', "url(#{data.result.url})").removeClass('cover-image contain-image').addClass(data.result.class)

  updatePostAudio = (data) ->
    if data
      $('#jquery_jplayer_1').data('url', data.url)
      $('#left-panel .audio .name').text(data.name)
    else
      $('#jquery_jplayer_1').data('url', null)
      $('#left-panel .audio .name').text('None')
    $('body').trigger('reset-audio-player')

  # handle audio uploads
  $('#audio-upload .fileinput-button input').fileupload
    dataType: "json"
    type: 'PUT'
    maxFileSize: 10000000
    add: (e,data) ->
      types = /(\.|\/)(mp3|m4a|ogg)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.submit()
      else
        alert("#{file.name} is not a mp3, m4a, or ogg file")
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#audio-upload .loading').text("#{progress}%")
    done: (e,data) ->
      $('#audio-upload .loading').text('')
      updatePostAudio(data.result)

  # handle audio remove
  $('#left-panel .audio').on 'click', '.remove', (e) ->
    e.preventDefault
    $.ajax
      url: $(@).attr('href')
      type: 'PUT'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        updatePostAudio(null)
    false

  # submit the form
  $('.editor-save, .editor-publish').on 'click', (e) ->
    self = $(@)
    return if $(@).hasClass('disabled')
    $('.editor-save, .editor-publish').addClass('disabled')

    data = {'post':{}}
    if $('#post-title:visible').length
      data['post']['title'] = $.trim($('#post-title').text())
    else
      data['post']['title'] = $.trim($('#post-picture-title h1').text())

    data['post']['content'] = $.trim($('#post-body').html())
    data['post']['style'] = $('#left-panel .post-style .content li.on').data('value')

    if $(@).hasClass('editor-publish')
      data['post']['status'] = 'active'
      $(@).find('.name').text('Publishing')
    else
      data['post']['status'] = 'idea'
      $(@).find('.name').text('Saving')

    $.ajax
      url: $('#editor-submit-url').data('url')
      data: data
      type: 'put'
      dataType: 'JSON'
      success: (data, textStatus, jqXHR) ->
        if self.hasClass('editor-publish')
          window.location = data.url
      complete: ->
        $('.editor-save, .editor-publish').removeClass('disabled')
        $('.editor-save .name').text('Save As Idea')
        $('.editor-publish .name').text('Publish')
      error: (jqXHR, textStatus, errorThrown) ->
        data = $.parseJSON(jqXHR.responseText)
        if data.errors && data.errors.primary_channel
          $('#left-panel .channels').tooltip
            placement: 'right'
            html: true
            title: "
                You must add a channel before publishing.
                Click the + to the left to choose an existing channel. <a href='/channels/new' data-skip-pjax='true' target='_blank'>Click here</a> to create a new one, and then add it with the + to the left.
              "
            trigger: 'manual'
            classes: 'error'
            width: 200
          $('#left-panel .channels').tooltip('show')

  # auto save the post every x seconds
  $('.editor').livequery ->
    if $('#post-data').data('d').status != 'active'
      $('body').everyTime "30s", 'save-form', ->
        $('.editor-save').click()

  # save on ctrl + s
  $('body,#post-title,#post-body').bind 'keydown.ctrl_s', (e) ->
    e.preventDefault()
    $('.editor-save').click()
    false

  # save on command (mac) + s
  $('body,#post-title,#post-body').bind 'keydown.meta_s', (e) ->
    e.preventDefault()
    $('.editor-save').click()
    false

  # capture ctrl + left
  $('body,#post-title,#post-body').bind 'keydown.ctrl_left', (e) ->
    e.preventDefault()
    false

  # capture command (mac) + left
  $('body,#post-title,#post-body').bind 'keydown.meta_left', (e) ->
    e.preventDefault()
    false

  # toggle text post styles
  $('.post-style .content li').click (e) ->
    $('#posts-edit').removeClass('default small-image half-page full-page').addClass($(@).data('value'))
    $('.post-style .content li').removeClass('on')
    $(@).addClass('on')
    unless $(@).data('value') == 'full-page'
      $('#picture-wrapper,.white-wrap,#post-picture-title').removeAttr('style')
    $.scrollTo '0',
      duration: 300
      easing:'easeInOutCubic'

  # toggle channel autocomplete
  $('#left-panel .channels .icon-plus').click (e) ->
    $('#left-panel .channels').tooltip('destroy')
    $('#channel-autocomplete').animate {width: 'toggle'}, 200, ->
      $('#channel-autocomplete input').focus()
      $('.autocomplete-suggestions').css('width': $('#channel-autocomplete').css('width'))

  updatePostChannel = ->
    if $('#left-panel .channels li').length > 0
      target = $('#left-panel .channels li:first a:not(.remove)')
      $('.post-full .post-channel').attr('href': target.attr('href')).text(target.find('.name').text())
    else
      $('.post-full .post-channel').attr('href', '#').text('none')

  $('#channel-autocomplete input').autocomplete
    serviceUrl: '/search/channels'
    minChars: 3
    deferRequestBy: 50
    noCache: false
    onSelect: (suggestion) ->
      $.ajax
        url: "#{$('#post-data').data('d').url}/channels"
        type: 'PUT'
        dataType: 'json'
        data: {channel_id: suggestion.data.id}
        success: (data, textStatus, jqXHR) ->
          $('#left-panel .channels ul').append(data.channel.list_item)
          $('#left-panel .channels .icon-plus').click()
          $('#channel-autocomplete input').val('')
          updatePostChannel()

  $('#left-panel .channels').on 'click', '.remove', (e) ->
    e.preventDefault()
    self = $(@)
    $.ajax
      url: $(@).attr('href')
      type: 'DELETE'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        self.parents('li:first').remove()
        updatePostChannel()
    false
