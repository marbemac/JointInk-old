jQuery ->

  if $('#post-body').length
    $('#post-body').redactor
      air: true
      airButtons: ['formatting','bold','italic','|','unorderedlist','orderedlist','link']
      formattingTags: ['h3','h4','p','blockquote']

  $('#post-picture-title h1, #post-title, #post-body').attr('contenteditable', true)

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
      $('.fileinput-button .loading').text("#{progress}%")
    done: (e,data) ->
      $('.fileinput-button .loading').text('')
      $('#picture-wrapper .image').css('background-image', "url(#{data.result.url})").removeClass('cover-image contain-image').addClass(data.result.class)

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
        else
          # $('.last-saved .timeago').html($.timeago(data.post.updated_at))
      complete: ->
        $('.editor-save, .editor-publish').removeClass('disabled')
        $('.editor-save .name').text('Save')
        $('.editor-publish .name').text('Publish')

  # auto save the post every x seconds
  $('.editor').livequery ->
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

  # toggle text post styles
  $('.post-style .content div').click (e) ->
    $('#posts-edit').removeClass('default half-page full-page').addClass($(@).data('value'))
    unless $(@).data('value') == 'full-page'
      $('#picture-wrapper,.white-wrap').removeAttr('style')