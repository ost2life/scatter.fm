previousPoint = null

$("#placeholder").bind "plothover", (event, pos, item) ->
    return if not item or previousPoint == item.seriesIndex
    previousPoint = item.seriesIndex
    $("#tooltip").remove()
    window.plot.unhighlight()
    scrobble = item.series.scrobble
    showTooltip item.pageX, item.pageY, scrobble
    for indices in track_indices[scrobble.artist + "#" + scrobble.track]
        window.plot.highlight indices.series_index, indices.datapoint_index

showTooltip = (x, y, scrobble) ->
    tipWidth = 300
    tipHeight = 66
    xOffset = 5
    yOffset = 5
    scrollLeft = window.pageXOffset
    scrollTop = window.pageYOffset
    docWidth = window.innerWidth - 15
    docHeight = window.innerHeight - 8

    top = if y + tipHeight - scrollTop < docHeight
    then y
    else y - tipHeight - yOffset

    css = top: top

    if x + tipWidth - scrollLeft < docWidth
    then css.left = x + xOffset
    else css.right = docWidth - x + xOffset

    dateString = scrobble.date.toString("HH:mm, ddd dd MMM yyyy")
    $("<div id='tooltip'>").
    append($("<div id='text'>").
        append($("<div id='name'>").text scrobble.track).
        append($("<div id='artist'>").text scrobble.artist).
        append($("<div id='album'>").text scrobble.album).
        append($("<div id='date'>").text dateString)
    ).css(css).appendTo("body").fadeIn(200)

    if scrobble.image
        img = new Image()
        img.src = scrobble.image
        $(img).prependTo "#tooltip"

$("#searchForm").submit (e) ->
    e.preventDefault()
    return if not window.scrobbles
    window.location.hash = "#" + $("#search").val()
    resetAndRedrawScrobbles window.scrobbles

user = $.url.param "user"
if user
    $("#user").val(user)
    $("#lastfm_link").attr "href", "http://www.last.fm/user/" + user
    responses_received = 0
    redraw_on_response_number = 1
    fetch_scrobbles {
        user: user
        onprogress: (e) ->
            responses_received++
            if responses_received == redraw_on_response_number
                redraw_on_response_number *= 2
                resetAndRedrawScrobbles e.scrobbles
            $("#fetchStatus").text e.thisPage - 2 + " to go."
        onfinished: (scrobbles) ->
            $("#fetchThrobber").hide()
            resetAndRedrawScrobbles scrobbles  # force redraw
        onerror: (errCode, message) ->
            $("#fetchThrobber").hide()
            alert "Last.FM Error: " + message
    }
    $("#fetchThrobber").show()

if window.location.hash
    $("#search").val(window.location.hash.substring 1)

$(window).bind "hashchange", () ->
    $("#search").val(window.location.hash.substring 1)
