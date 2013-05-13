jQuery ->

  drawPostViewsChart = ->
    $container = $('#post-views-chart')
    categories = _.map($container.data('data1'), (data) -> data['stat']['time'])
    viewDataPoints = _.map($container.data('data1'), (data) -> parseInt(data['stat']['value']))
    readDataPoints = if $container.data('data2') then _.map($container.data('data2'), (data) -> parseInt(data['stat']['value'])) else null
    series = [{
      data: viewDataPoints
      name: 'views'
      color: '#8FBCD9'
    }]

    if readDataPoints
      series.push({
        data: readDataPoints
        name: 'reads'
        color: '#ABD998'
      })

    $container.highcharts({
      chart:
        type: 'column'
        margin: [0,0,0,0]
        spacingTop: 0
        spacingRight: 0
        spacingBottom: 0
        spacingLeft: 0
        height: ($container.parent().outerHeight() - $container.siblings('.numbers:first').outerHeight())
      plotOptions:
        column:
          size: '100%'
          pointPadding: 0
          groupPadding: 0.1
      legend:
        enabled: false
      xAxis:
        labels:
          enabled: false
        title:
          text: null
        tickWidth: 0
        lineWidth: 0
        categories: categories
      yAxis:
        labels:
          enabled: false
        title:
          text: null
        gridLineWidth: 0
      title:
        text: null
      tooltip:
        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
        pointFormat: '<tr><td style="padding:0">{point.y} <span style="color:{series.color}"><b>{series.name}</b></span></td></tr>',
        footerFormat: '</table>',
        shared: true
        useHTML: true
      credits:
        enabled: false
      series: series
    });

  drawRecsChart = ->
    $container = $('#post-recs-chart')
    categories = _.map($container.data('data'), (data) -> data['stat']['time'])
    dataPoints = _.map($container.data('data'), (data) -> parseInt(data['stat']['value']))
    $container.highcharts({
      chart:
        type: 'line'
        margin: [0,0,0,0]
        spacingTop: 0
        spacingRight: 0
        spacingBottom: 0
        spacingLeft: 0
        height: ($container.parent().outerHeight() - $container.siblings('.numbers:first').outerHeight())
      plotOptions:
        line:
          size: '100%'
          pointPadding: 0
          groupPadding: 0
          color: '#8FBCD9'
      legend:
        enabled: false
      xAxis:
        labels:
          enabled: false
        title:
          text: null
        tickWidth: 0
        lineWidth: 0
        categories: categories
      yAxis:
        labels:
          enabled: false
        title:
          text: null
        gridLineWidth: 0
      title:
        text: null
      tooltip:
        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
        pointFormat: '<tr><td style="padding:0">{point.y} recommendations</td></tr>',
        footerFormat: '</table>',
        useHTML: true
      credits:
        enabled: false
      series: [{
        data: dataPoints
      }]
    });

  drawReferralsChart = ->
    $container = $('#post-referrals-chart')

    sourceData = _.map($container.data('data'), (data) -> {y: parseInt(data['value']), name: data['name']})

    $container.highcharts
      chart:
        type: 'pie'
        margin: [10,0,10,0]
        spacingTop: 0
        spacingRight: 0
        spacingBottom: 0
        spacingLeft: 0
        height: $container.parent().outerHeight()
      plotOptions:
        pie:
          shadow: false
          center: ['50%','50%']
      legend:
        enabled: false
      xAxis:
        labels:
          enabled: false
        title:
          text: null
        tickWidth: 0
        lineWidth: 0
      yAxis:
        labels:
          enabled: false
        title:
          text: null
        gridLineWidth: 0
      title:
        text: null
      tooltip:
        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
        pointFormat: '<tr><td style="padding:0">{point.y}% of views</td></tr>',
        footerFormat: '</table>',
        useHTML: true
      credits:
        enabled: false
      series: [
        {
          data: sourceData
          size: '70%'
          innerSize: '50%'
        }
      ]

  drawCharts = ->
    drawPostViewsChart()
    drawRecsChart()
    drawReferralsChart()

  $('.users-dashboard').livequery ->
    drawCharts()

  $('body').on 'click', '.dashboard-section.posts li:not(.on)', (e) ->
    $self = $(@)
    $.ajax
      url: $self.data('url')
      type: 'GET'
      dataType: 'JSON'
      complete: (data, textStatus) ->
        $('.dashboard-section.posts li').removeClass('on')
        $self.addClass('on')
        $('.post-analytics').html(data.responseText)
        drawCharts()


  $.event.special.debouncedresize.threshold = 300;
  $(window).on "debouncedresize", (event) ->
    drawCharts()