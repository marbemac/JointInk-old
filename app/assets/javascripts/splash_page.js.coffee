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
    $('.simple_form.user').trigger('reset-errors')

    unless username
      $('.simple_form.user').trigger('add-error', 'please input a username')
      return

    $.ajax
      url: self.data('url')
      type: 'GET'
      data: {username: username}
      dataType: 'JSON'
      success: (data, textStatus, jqXHR) ->
        if data.available == false
          $('.simple_form.user').trigger('add-error', 'that username is already taken')
          return

        $('.simple_form.user .extra,.simple_form.user .step-1,.simple_form.user .step-2').toggle()

  $('.simple_form.user').submit (e) ->
    if $(@).find('.claim:visible').length
      $(@).find('.claim').click()
      e.preventDefault()

  $('.simple_form.user .opposite').click (e) ->
    $('.simple_form.user').toggle()