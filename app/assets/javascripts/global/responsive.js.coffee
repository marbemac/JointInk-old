# adapted from foresight.js

speedConnectionStatus = null
#speedTestUri = 'http://foresightjs.appspot.com/speed-test/50K'
speedTestUri = 'http://www.getthisthat.com/speed-test/50K'
speedTestKB = 50
speedTestExpireMinutes = 60
minKbpsForHighbandwith = 250
localStorageKey = 'ttjs'
STATUS_LOADING = 'loading'
STATUS_COMPLETE = 'complete'
responsive = {
  device_screen_width: null,
  device_screen_height: null,
  device_pixel_ratio: null,
  device_pixel_ratio_rounded: null,
  bandwith: null,
  connection_type: null,
  connection_test_result: null,
  connection_kbps: null
}

initSpeedTest = ->
  # only check the connection speed once, if there is a status then we've
  # already got info or it already started
  return if speedConnectionStatus

  # if the device pixel ratio is 1, then no need to do a network connection
  # speed test since it can't show hi-res anyways
  if responsive.device_pixel_ratio is 1
    responsive.connection_test_result = "skip"
    speedConnectionStatus = STATUS_COMPLETE
    return

  # if we know the connection is 2g or 3g
  # don't even bother with the speed test, cuz its slow
  # Network connection feature detection referenced from Modernizr
  # Modernizr v2.5.3, www.modernizr.com
  # Copyright (c) Faruk Ates, Paul Irish, Alex Sexton
  # Available under the BSD and MIT licenses: www.modernizr.com/license/
  # https://github.com/Modernizr/Modernizr/blob/master/feature-detects/network-connection.js
  # Modified by Adam Bradley for Foresight.js
  connection = navigator.connection or type: "unknown" # polyfill
  # connection.CELL_2G
  # connection.CELL_3G
  isSlowConnection = connection.type is 3 or connection.type is 4 or /^[23]g$/.test(connection.type) # string value in new spec
  responsive.connection_type = connection.type
  if isSlowConnection
    # we know this connection is slow, don't bother even doing a speed test
    responsive.connection_test_result = "connTypeSlow"
    speedConnectionStatus = STATUS_COMPLETE
    return

  # check if a speed test has recently been completed and its
  # results are saved in the local storage
  try
    fsData = JSON.parse(localStorage.getItem(localStorageKey))
    if fsData isnt null
      if (new Date()).getTime() < fsData.exp
        # already have connection data within our desired timeframe
        # use this recent data instead of starting another test
        responsive.bandwith = fsData.bw
        responsive.connection_kbps = fsData.kbps
        responsive.connection_test_result = "localStorage"
        speedConnectionStatus = STATUS_COMPLETE
        return

  speedTestImg = document.createElement("img")
  endTime = undefined
  startTime = undefined
  speedTestTimeoutMS = undefined
  speedTestImg.onload = ->
    # speed test image download completed
    # figure out how long it took and an estimated connection speed
    endTime = (new Date()).getTime()
    duration = (endTime - startTime) / 1000
    duration = ((if duration > 1 then duration else 1)) # just to ensure we don't divide by 0
    responsive.connection_kbps = ((speedTestKB * 1024 * 8) / duration) / 1024
    responsive.bandwith = ((if responsive.connection_kbps >= minKbpsForHighbandwith then "high" else "low"))
    speedTestComplete "networkSuccess"

  speedTestImg.onerror = ->
    # fallback incase there was an error downloading the speed test image
    speedTestComplete "networkError", 5

  speedTestImg.onabort = ->
    # fallback incase there was an abort during the speed test image
    speedTestComplete "networkAbort", 5


  # begin the network connection speed test image download
  startTime = (new Date()).getTime()
  speedConnectionStatus = STATUS_LOADING

  # if this current document is SSL, make sure this speed test request
  # uses https so there are no ugly security warnings from the browser
  speedTestUri = speedTestUri.replace("http:", "https:")  if document.location.protocol is "https:"
  speedTestImg.src = speedTestUri + "?r=" + Math.random()

  # calculate the maximum number of milliseconds it 'should' take to download an XX Kbps file
  # set a timeout so that if the speed test download takes too long
  # than it isn't a 'high-bandwith' and ignore what the test image .onload has to say
  # this is used so we don't wait too long on a speed test response
  # Adding 350ms to account for TCP slow start, quickAndDirty === TRUE
  speedTestTimeoutMS = (((speedTestKB * 8) / minKbpsForHighbandwith) * 1000) + 350
  setTimeout (->
    speedTestComplete "networkSlow"
  ), speedTestTimeoutMS


speedTestComplete = (connTestResult, expireMinutes) ->
  # if we haven't already gotten a speed connection status then save the info
  return if speedConnectionStatus is STATUS_COMPLETE
  console.log connTestResult

  # first one with an answer wins
  speedConnectionStatus = STATUS_COMPLETE
  responsive.connection_test_result = connTestResult
  try
    expireMinutes = speedTestExpireMinutes unless expireMinutes

    fsDataToSet =
      kbps: responsive.connection_kbps
      bw: responsive.bandwith
      exp: (new Date()).getTime() + (expireMinutes * 60000)

    console.log responsive
    # SET the client cookie for use on the server
    $.cookie("clientInfo", JSON.stringify(responsive), { expires : 1 });
    localStorage.setItem localStorageKey, JSON.stringify(fsDataToSet)

# get this devices dimensions
responsive.device_screen_height = screen.height
responsive.device_screen_width = screen.width

# get this device's pixel ratio
responsive.device_pixel_ratio = if window.devicePixelRatio then window.devicePixelRatio else 1
responsive.device_pixel_ratio_rounded = Math.round(responsive.device_pixel_ratio)

# DOM does not need to be ready to begin the network connection speed test
initSpeedTest()