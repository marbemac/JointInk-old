jQuery ->

  $('#post-picture-title h1, #post-title, #post-body').attr('contenteditable', true)

  `
  function pasteHtmlAtCaret(html) {
    var sel, range;
    if (window.getSelection) {
      // IE9 and non-IE
      sel = window.getSelection();
      if (sel.getRangeAt && sel.rangeCount) {
      range = sel.getRangeAt(0);
        range.deleteContents();

        // Range.createContextualFragment() would be useful here but is
        // non-standard and not supported in all browsers (IE9, for one)
        var el = document.createElement("div");
        el.innerHTML = html;
        var frag = document.createDocumentFragment(), node, lastNode;
        while ( (node = el.firstChild) ) {
        lastNode = frag.appendChild(node);
        }
        range.insertNode(frag);

        // Preserve the selection
        if (lastNode) {
        range = range.cloneRange();
          range.setStartAfter(lastNode);
          range.collapse(true);
          sel.removeAllRanges();
          sel.addRange(range);
        }
      }
    } else if (document.selection && document.selection.type != "Control") {
    // IE < 9
    document.selection.createRange().pasteHTML(html);
    }
  }
  `

  # start the redactor editor
  if $('#post-body').length
    $('#post-body').redactor
      fixed: true
      fixedBox: true
      fixedTop: 20
      buttons: ['formatting','bold','italic','|','unorderedlist','orderedlist','link','customimage']
      allowedTags: ["a", "p", "b", "i", "img", "blockquote", "ul", "ol", "li", "h3", "h4", "div"]
      formattingTags: ['h3','h4','p','blockquote']
      observeImages: false
      convertDivs: false
      buttonsCustom:
        customimage:
          title: 'Add Inline Image'
          callback: (obj, event, key) ->
            pasteHtmlAtCaret('<div class="inline-image-placeholder hide"></div>')
            target = $('.inline-image-placeholder')
            content = target.parent().html()
            if target.parent().is('p') && $.trim(content.replace('<div class="inline-image-placeholder hide"></div>','').replace('<br />','').replace('<br>','')) == ''
              $('.inline-image-placeholder').unwrap()
              $('#inline-image-edit').reveal
                closed: ->
                  $('#post-body .inline-image-placeholder').remove()
            else
              $('.inline-image-placeholder').remove()
              alert('You can only add images on new, blank lines.')

  # prompt them before they leave the page, unless they are publishing or discarding
  $(window).bind 'beforeunload', ->
    unless $('.editor-publish,.editor-discard').hasClass('disabled')
      return 'Are you sure you want to leave?'

  # handle main photo uploads
  $('#picture-wrapper .fileinput-button input').fileupload
    dataType: "text"
    type: 'POST'
    paramName: 'post[photo]'
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
      result = $.parseJSON(data.result)
      $('#picture-wrapper .fileinput-button .loading').text('')
      $('#picture-wrapper .image').css('background-image', "url(#{result.url})").removeClass('cover-image contain-image').addClass(result.class)

  # handle inline photo uploads
  $('#inline-image-edit .fileinput-button input').livequery ->
    self = $(@).parents('#inline-image-edit:first')
    $(@).fileupload
      dataType: "text"
      type: 'POST'
      paramName: 'post[photo]'
      add: (e,data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.submit()
        else
          alert("#{file.name} is not a gif, jpeg, or png image file")
      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        self.find('.fileinput-button .loading').text(" #{progress}%")
      done: (e,data) ->
        result = $.parseJSON(data.result)
        self.find('.fileinput-button .loading').text('')
        $('#post-body .inline-image-placeholder').after("<div class='inline-image'><img src='#{result.url}' /><p>Caption...</p><div class='options' contenteditable='false'><div class='small caption button'>Toggle Caption</div><div class='small remove button'>Remove Image</div><div class='button-group'><div class='small align button' data-value='left'>Left</div><div class='small align center button' data-value='center'>Center</div><div class='small align button' data-value='right'>Right</div></div></div></div>")
        $('#post-body').find('br').remove()
        self.trigger('reveal:close')

  # inline images edit options
  $('#post-body').on 'click', '.inline-image .remove', (e) ->
    $(@).parents('.inline-image:first').remove()
  $('#post-body').on 'click', '.inline-image .caption', (e) ->
    $(@).parents('.inline-image:first').toggleClass('show-caption')
  $('#post-body').on 'click', '.inline-image .align', (e) ->
    $(@).parents('.inline-image:first').removeClass('left center right').addClass($(@).data('value'))

  # inline image resizing
  $('.inline-image').livequery ->
    $(@).resizable
      handles: 'e'
      minWidth: 220
      containment: $('#post-body')

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

    # remove jquery-ui resizing classes and markup
    content = $('#post-body').clone()
    content.find('.ui-resizable').removeClass('ui-resizable').find('.ui-resizable-handle').remove()
    data['post']['content'] = $.trim(content.html())

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

  ### CHANNELS ###

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

  ### ATTRIBUTION ###

  # toggle attribution field
  $('#right-panel .attribution .icon-plus').click (e) ->
    $('#right-panel .attribution').tooltip('destroy')
    $('.attribution #attribution-form').animate {width: 'toggle'}, 200, ->
      $('.attribution input').focus()

  $('.attribution .submit').click (e) ->
    $.ajax
      url: "#{$('#post-data').data('d').url}"
      type: 'PUT'
      dataType: 'json'
      data: {post: {attribution_link: $('.attribution input').val()}}
      success: (data, textStatus, jqXHR) ->
        link = data.post.post.attribution_link
        $('#right-panel .attribution li').show()
        $('#right-panel .attribution li .name').text(link).parent("a").attr("href", link)
        $('#right-panel .attribution .icon-plus').click()
        $('#right-panel .attribution input').val('')

  $('#right-panel .attribution').on 'click', '.remove', (e) ->
    e.preventDefault()
    self = $(@)
    $.ajax
      url: $(@).attr('href')
      type: 'PUT'
      dataType: 'json'
      data: {post: {attribution_link: null}}
      success: (data, textStatus, jqXHR) ->
        self.parents('li:first').hide()
    false
