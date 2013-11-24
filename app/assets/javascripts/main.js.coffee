$ ->

  $.stellar horizontalScrolling: false

  # $('.topfold-header').waypoint ->
  #       $(this).addClass('enabled')
  #     , 
  #       offset:-340

  $('.topfold-header').waypoint 'sticky'
      , 
        offset: -340
        stuckClass: 'enabled'
        handler: -> 
          if ($(this).height() == 60) # scrolling down
            $(this).find('.topfold-header').addClass('small')
          else
            $(this).find('.topfold-header').removeClass('small')