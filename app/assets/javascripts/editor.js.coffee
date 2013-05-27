#= require global/to-markdown
#= require showdown
#= require_self

jQuery ->

  # plain JS function we found on the internet
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

  $('.post-show__title h1, .post-show__body').livequery ->
    $(@).attr('contenteditable', true)

  # capture changes to the title and clean (main purpose of this is copy paste)
  $('body').on 'paste', '.post-show__title h1', (e) ->
    e.preventDefault()
    document.execCommand('inserttext', false, prompt('Paste something.'))

  # start the redactor editor
  $('.post-show__body').livequery ->
    $(@).redactor
      fixed: true
      fixedBox: true
      fixedTop: 40
      buttons: ['formatting','bold','italic','|','unorderedlist','orderedlist','link','image','html']
      allowedTags: ["a", "p", "b", "i", "img", "blockquote", "ul", "ol", "li", "h3", "h4"]
      formattingTags: ['h3','h4','p','blockquote']
      observeImages: false
      convertDivs: true
      buttonsCustom:
        image:
          title: 'Add Inline Image'
          callback: (obj, event, key) ->

            # insert the placeholder element, clean up any extra empty markup
            pasteHtmlAtCaret('<img src="" class="inline-image-placeholder hide" />')
            target = $('.inline-image-placeholder')
            parent = target.closest('p')
            content = parent.clone()
            removed = 1
            while removed > 0
              removed = content.find('*').filter(-> $.trim(@.innerHTML) == '').remove().length

            if parent.parent().hasClass('post-show__body') && $.trim(content.html()) == ''
              $('#inline-image-edit').reveal
                closed: ->
                  $('.post-show__body .inline-image-placeholder').remove()
            else
              $('.inline-image-placeholder').remove()
              alert('You can only add images on new, blank lines.')

        html:
          title: 'View Markdown / Distraction Free Mode'
          callback: (obj, event, key) ->
            # change the button title
            if $('.redactor_btn_html').data('old-title')
              title = $('.redactor_btn_html').data('old-title')
              $('.redactor_btn_html').data('old-title', $('.redactor_btn_html').attr('title'))
              $('.redactor_btn_html').attr('title', title)
            else
              $('.redactor_btn_html').data('old-title', $('.redactor_btn_html').attr('title'))
              $('.redactor_btn_html').attr('title', 'Exit Distraction Free Mode')

            # toggle showing the markdown editor versus the normal post editor
            if $('.post-show__markdown').is(':visible')
              $('.redactor_toolbar li,.editor-bar').show()
              $('.redactor_btn_html').parent().show()
            else
              $('.redactor_toolbar li,.editor-bar').hide()
              $('.redactor_btn_html').parent().show()
            $('#post-editor').toggleClass('markdown-on')

            $('.post-show__markdown textarea').trigger('autosize')
            $.scrollTo(0, 400)

    # Method that converts the HTML contents to Markdown
    markdownize = (content) ->
      html = content.split("\n").map($.trim).filter (line) ->
        line != ""
      .join("\n")
      toMarkdown(html)

    htmlToMarkdown = (content) ->
      markdown = markdownize(content)
      if ($('.post-show__markdown textarea').get(0).value == markdown)
        return
      $('.post-show__markdown textarea').get(0).value = markdown

    # Update Markdown every time content is modified
    $('.post-show__body').bind 'keyup', (event) ->
      htmlToMarkdown($(@).html())

    # Update html when markdown content is modified
    converter = new Showdown.converter();
    $('.post-show__markdown textarea').bind 'keyup', (event) ->
      $('.post-show__body').html(converter.makeHtml($(@).val()))

    htmlToMarkdown($('.post-show__body').html())

    # auto resize the markdown textarea
    $('.post-show__markdown textarea').autosize()

    # refresh the markdown whenever redactor is interacted with
    $('.post-show').on 'click', '.redactor_toolbar > li', (e) ->
      htmlToMarkdown($('.post-show__body').html())

  # toggle markdown hints
  $('body').on 'click', '.markdown-help .head span,.markdown-help .hide-hints', (e) ->
    $('.markdown-help .content').toggle()

  # prompt them before they leave the page, unless they are publishing or discarding
  $(window).bind 'beforeunload', ->
    unless $('.editor-publish,.editor-discard').hasClass('disabled')
      return 'Are you sure you want to leave?'

  # handle main photo uploads
  $('.post-show__fileinput-button input').livequery ->
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
        $('.post-show__fileinput-button .loading').text(" #{progress}%")
      done: (e,data) ->
        console.log e
        console.log data
        result = $.parseJSON(data.result)
        console.log result
        $('.post-show__fileinput-button .loading').text('')
        $('.post-show__main-image').addClass('post-show__main-image--present')
        $('.post-show__main-image .image').css('background-image', "url(#{result.url})")
        $('.post-show__main-image img').attr('src', result.url)

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
        $('.post-show__body .inline-image-placeholder').attr('src', result.url).removeClass('inline-image-placeholder hide')
        $('.post-show__body').find('br').remove()
        htmlToMarkdown($('.post-show__body').html())
        self.trigger('reveal:close')

  updatePostAudio = (data) ->
    if data
#      $('#jquery_jplayer_1').data('url', data.url)
      $('.editor-audio .name').text("Audio: #{data.name}")
      $('.editor-audio .editor-audio-add').hide()
      $('.editor-audio .editor-audio-remove').show()
      $('.editor-audio .display').removeClass('fileinput-button')
    else
#      $('#jquery_jplayer_1').data('url', null)
      $('.editor-audio .name').text('Audio: None')
      $('.editor-audio .editor-audio-add').show()
      $('.editor-audio .editor-audio-remove').hide()
      $('.editor-audio .display').addClass('fileinput-button')
#    $('body').trigger('reset-audio-player')

  # handle audio uploads
  $('.editor-audio .fileinput-button input').livequery ->
    return if $(@).hasClass('remove')

    $(@).fileupload
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
        $('.editor-audio .name span').text("#{progress}%")
      done: (e,data) ->
        updatePostAudio(data.result)

  # handle audio remove
  $('.editor-audio').on 'click', '.display:not(.fileinput-button)', (e) ->
    e.preventDefault
    $.ajax
      url: $(@).data('remove-url')
      type: 'PUT'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        updatePostAudio(null)
    false

  # submit the form
  $('body').on 'click', '.editor-save, .editor-publish', (e) ->
    self = $(@)
    return if $(@).hasClass('disabled')
    $('.editor-save, .editor-publish').addClass('disabled')
    $('.editor-bar__errors').hide().empty()

    data = {'post':{}}
    data['post']['title'] = $.trim($('.post-show__title h1').text())
    data['post']['content'] = $.trim($('.post-show__markdown textarea').val())
    data['post']['style'] = $('.editor-style-item.on').data('value')

    if $(@).hasClass('editor-publish')
      data['post']['status'] = 'active'
    else
      data['post']['status'] = 'draft'

    $.ajax
      url: $('#editor-submit-url').data('url')
      data: data
      type: 'put'
      dataType: 'JSON'
      success: (data, textStatus, jqXHR) ->
        if self.hasClass('editor-publish')
          $('.editor-actions .status').text('published')
          window.location = data.url
        if self.hasClass('editor-save')
          $('.editor-actions .status').html("draft, saved <span title='#{new Date().toISOString()}'></span>")
          $('.editor-actions .status span').timeago()
          $('.editor-save,.editor-publish').removeClass('disabled')
      error: (jqXHR, textStatus, errorThrown) ->
        $('.editor-save,.editor-publish').removeClass('disabled')
        data = $.parseJSON(jqXHR.responseText)

        if data.errors
          $('.editor-bar__errors').show()
          for error in data.errors
            $('.editor-bar__errors').append("<li>#{error}</li>")

  # auto save the post every x seconds
#  $('.editor').livequery ->
#    if $('#post-data').data('d').status != 'active'
#      $('body').everyTime "30s", 'save-form', ->
#        $('.editor-save').click()

  # save on ctrl + s
  $('body,.post-show__title,.post-show__body').bind 'keydown', 'ctrl+s', (e) ->
    e.preventDefault()
    $('.editor-save').click()
    false
  # save on command (mac) + s
  .bind 'keydown', 'meta+s', (e) ->
    e.preventDefault()
    $('.editor-save').click()
    false
  # capture ctrl + left
  .bind 'keydown', 'ctrl+left', (e) ->
    e.preventDefault()
    false
  # capture command (mac) + left
  .bind 'keydown', 'meta+left', (e) ->
    e.preventDefault()
    false

  # toggle text post styles
  $('body').on 'click', '.editor-style-item', (e) ->
    $('.post-show').removeClass('post-show--default-article post-show--large-image-article post-show--cover-page-article post-show--text-on-image post-show--cover-screen post-show--fit-on-screen').addClass("post-show--#{$(@).data('value')}")
    $('.editor-style-item').removeClass('on')
    $(@).addClass('on')
    $('.editor-style .display .name').text($(@).text())
    $.scrollTo '0',
      duration: 300
      easing:'easeInOutCubic'

  ### CHANNELS ###

  # toggle channel autocomplete
  updatePostChannel = ->
    channel_count = $('.editor-channels .menu li').length

    if channel_count
      target = $('.editor-channels .menu li:first .name')
      $('.post-show__text-meta__channel').attr('href': target.attr('href')).text(target.text())
    else
      $('.post-show__text-meta__channel').attr('href', '#').text('none')

    if channel_count == 1
      $('.editor-channels .display .name').text('1 Channel')
    else
      $('.editor-channels .display .name').text("#{channel_count} Channels")

  $('#editor-channel-autocomplete input').livequery ->
    $(@).autocomplete
      serviceUrl: '/search/channels'
      minChars: 3
      deferRequestBy: 50
      noCache: false
      appendTo: '.editor-channels .autocomplete'
      position: 'static'
      onSelect: (suggestion) ->
        $.ajax
          url: "#{$('#post-data').data('d').url}/channels"
          type: 'PUT'
          dataType: 'json'
          data: {channel_id: suggestion.data.id}
          success: (data, textStatus, jqXHR) ->
            $('.editor-channels .menu ul').append(data.channel.list_item)
            $('#editor-channel-autocomplete input').val('')
            updatePostChannel()

  $('body').on 'click', '.editor-channel-remove', (e) ->
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