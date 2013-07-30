jQuery ->

  if document.location.hostname.indexOf("lvh.me") != -1
    $.cloudinary.config({ cloud_name: 'limelight', api_key: '731949947482814'})
  else
    $.cloudinary.config({ cloud_name: 'hbbxbyt3m', api_key: '777285174847975'})

  retina = window.devicePixelRatio > 1
  img_max_width = 2000
  webp = null
  webp_supported = null
  if webp_supported == null
    webp = $.Deferred()
    webp_canary = new Image()
    webp_canary.onerror = webp.reject
    webp_canary.onload = webp.resolve
    webp_canary.src = 'data:image/webp;base64,UklGRjIAAABXRUJQVlA4ICYAAACyAgCdASoBAAEALmk0mk0iIiIiIgBoSygABc6zbAAA/v56QAAAAA=='

    webp.done ->
      webp_supported = true
      console.log 'webp supported'
      .fail ->
        webp_supported = false

  generate_options = (target, photo_id) ->
    width = null
    width = target.attr('width')
    width = target.data('width') unless width
    width = target.width() unless width
    width *= 1.5 if width && retina
    width = Math.round(Math.min(width, img_max_width)/100)*100 if width

    height = null
    height = target.attr('height') if target.attr('height')
    height = target.data('height') if target.data('height')
    height *= 1.5 if height && retina
    height = Math.round(height) if height

    crop = null
    crop = target.data('crop') if target.data('crop')

    gravity = null
    gravity = target.data('gravity') if target.data('gravity')

    options = { 'width': width, 'crop': 'limit', quality: 80 }
    options['width'] = width if width
    options['height'] = height if height
    options['crop'] = crop if crop
    options['gravity'] = gravity if gravity

    if webp_supported
      options['format'] = 'webp'

    options

  generate_photo_id = (target) ->
    source = target.data('src')
    if source && webp_supported
      source.split('.').slice(0, -1).join('.')
    else
      source

  setTimeout ->

    $('.cn-bg-img').livequery ->
      photo_id = generate_photo_id($(@))
      return unless photo_id
      $(@).css('background-image', "url(#{$.cloudinary.url(photo_id, generate_options($(@), photo_id))})")

    $('.cn-img').livequery ->
      photo_id = generate_photo_id($(@))
      return unless photo_id
      $(@).attr('src', $.cloudinary.url(photo_id, generate_options($(@), photo_id)))

  , 100