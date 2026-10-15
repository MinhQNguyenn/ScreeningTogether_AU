extends AudioStreamPlayer

# Same track, looping and volume as the waiting-room game.
const MUSIC := preload("res://assets/audio/alex-morgan-lofi-cocktail-bar-568153.mp3")
var browser_callback: JavaScriptObject

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	stream = MUSIC.duplicate()
	stream.loop = true
	volume_db = -22.0
	play()
	if OS.has_feature("web"):
		browser_callback = JavaScriptBridge.create_callback(_set_browser_muted)
		JavaScriptBridge.get_interface("window").screeningGameMusic = browser_callback
		JavaScriptBridge.eval("window.addEventListener('message', function(e) { if (e.origin === location.origin && e.source === window.parent && e.data && e.data.type === 'screening-music-muted' && typeof e.data.muted === 'boolean') window.screeningGameMusic(e.data.muted); }); window.parent.postMessage({type:'screening-music-ready'}, location.origin);")

func _set_browser_muted(arguments: Array) -> void:
	if not arguments.is_empty():
		stream_paused = bool(arguments[0])
