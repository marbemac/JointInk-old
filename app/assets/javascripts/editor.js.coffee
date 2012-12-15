jQuery ->

  CKEDITOR.disableAutoInline = true;
  if $('#post-body').length
    editor = CKEDITOR.inline( document.getElementById( 'post-body' ) )

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
    console.log 'foo'
    self = $(@)
    return if $(@).hasClass('disabled')
    $('.editor-save, .editor-publish').addClass('disabled')

    data = {'post':{}}
    data['post']['title'] = $.trim($('#post-title').text())
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

  $('.cke_button__bold_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-bold'))
  $('.cke_button__italic_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-italic'))
  $('.cke_button__button-h1_icon').livequery ->
    $(@).replaceWith($('<span/>').addClass('icon icon-h1').text('H1'))
  $('.cke_button__button-h2_icon').livequery ->
    $(@).replaceWith($('<span/>').addClass('icon icon-h1').text('H2'))
  $('.cke_button__blockquote_icon').livequery ->
    $(@).replaceWith($('<span/>').addClass('icon icon-blockquote').html('&quot;'))
  $('.cke_button__link_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-link'))
  $('.cke_button__unlink_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-link unlink'))
  $('.cke_button__numberedlist_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-list-ol'))
  $('.cke_button__bulletedlist_icon').livequery ->
    $(@).replaceWith($('<i/>').addClass('icon icon-list-ul'))