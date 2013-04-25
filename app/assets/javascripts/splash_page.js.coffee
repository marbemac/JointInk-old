#= require jquery_ujs
#= require jquery.easing
#= require global/global_functions
#= require_self

jQuery ->

  if $('.login-signup').length > 0
    setTimeout ->
      $('.login-signup').animate({'margin-top':"-#{$('.login-signup').height()}px"}, 1000, 'easeOutBounce')
    , 700

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

  $('.signup-form').submit (e) ->
    if $(@).find('.claim:visible').length
      $(@).find('.claim').click()
      e.preventDefault()

  $('.signup-form .opposite,.signin-form .opposite').click (e) ->
    $('.signup-form,.signin-form').toggle()