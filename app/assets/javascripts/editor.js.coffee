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
    data['post']['style'] = $('#left-panel .post-style .content > div.on').data('value')

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

  # auto save the post every x seconds
#  $('.editor').livequery ->
#    $('body').everyTime "30s", 'save-form', ->
#      $('.editor-save').click()

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
  $('.post-style .content div').click (e) ->
    $('#posts-edit').removeClass('default small-image half-page full-page').addClass($(@).data('value'))
    $('.post-style .content div').removeClass('on')
    $(@).addClass('on')
    unless $(@).data('value') == 'full-page'
      $('#picture-wrapper,.white-wrap,#post-picture-title').removeAttr('style')
    $.scrollTo '0',
      duration: 300
      easing:'easeInOutCubic'