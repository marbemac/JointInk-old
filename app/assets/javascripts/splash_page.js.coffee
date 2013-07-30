#= require jquery_ujs
#= require jquery.easing
#= require global/global_functions
#= require jquery.scrollTo.js
#= require global/images
#= require swipe
#= require_self

jQuery ->

  if $('.login-signup').length > 0
    $(window).scrollTop(0)
    setTimeout ->
      $('.login-signup').animate({'margin-top':"-#{$('.login-signup').height()}px"}, 1000, 'easeOutBounce')
    , 1000

  $('.login-signup .claim').click (e) ->
    self = $(@)
    username = $.trim($('.username-input input').val())
    $('.signup-form').trigger('reset-errors')

    unless username
      $('.signup-form').trigger('add-error', 'please input a username')
      return

    $.ajax
      url: self.data('url')
      type: 'GET'
      data: {username: username}
      dataType: 'JSON'
      success: (data, textStatus, jqXHR) ->
        if data.available == false
          $('.signup-form').trigger('add-error', 'that username is already taken')
          return

        $('.signup-form .extra,.signup-form .step-1,.signup-form .step-2').toggle()
        setTimeout ->
          $(window).scrollTop($('.signup-form').height())
        , 1

  $('.signup-form #user_username').keypress (e) ->
    keycode = if e.keyCode then e.keyCode else e.which
    if keycode == 13
      $('.claim').click()
      e.preventDefault()

  $('.signup-form .opposite,.signin-form .opposite').click (e) ->
    $('.signup-form,.signin-form').toggle()
    setTimeout ->
      $(window).scrollTop($('.signup-form:visible,.signin-form:visible').height())
      $('.signup-form:visible input:visible:first,.signin-form:visible input:visible:first').focus()
    , 1

  window.publishSwiper = new Swipe document.getElementById('splash-publishing-slider'),
    speed: 800,
    auto: 5000,
    continuous: true,
    disableScroll: false,
    callback: (index, elem) ->
      $(".splash-page-publish-tabs li").removeClass('on')
      $(".splash-page-publish-tabs li[data-index='#{index}']").addClass('on')

  $(".splash-page-publish-tabs li").click (e) ->
    $(@).addClass('on').siblings().removeClass('on')
    window.publishSwiper.slide($(@).data('index'), 800)

  $('.splash-page-lets-go').click (e) ->
    $.scrollTo($('.login-signup'), 1000)
    $('#user_username').focus()