extends Node

signal locale_changed

const CATALOG := preload("res://i18n/messages.gd")
const LOCALES := ["en", "zh_CN", "ar", "vi", "zh_HK"]
const NAMES := ["English", "普通话（简体）", "العربية", "Tiếng Việt", "廣東話（繁體）"]
var locale := "en"
var selector: OptionButton
var browser_callback: JavaScriptObject


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in range(1, LOCALES.size()):
		var translation := Translation.new()
		translation.set_locale(LOCALES[index])
		for source in CATALOG.STRINGS:
			translation.add_message(source, CATALOG.STRINGS[source][index - 1])
		TranslationServer.add_translation(translation)
	var initial := "en"
	if OS.has_feature("web"):
		initial = str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('lang') || (() => { try { return localStorage.getItem('screening-game-language') || localStorage.getItem('i18nextLng') || 'en'; } catch (_) { return 'en'; } })()"))
		browser_callback = JavaScriptBridge.create_callback(_on_browser_language)
		JavaScriptBridge.get_interface("window").screeningGameLanguage = browser_callback
		JavaScriptBridge.eval("window.addEventListener('message', function(e) { if(e.origin === location.origin && e.source === window.parent && e.data && e.data.type === 'screening-language') window.screeningGameLanguage(String(e.data.language)); }); window.parent.postMessage({type:'screening-game-ready'}, location.origin);")
	else:
		var config := ConfigFile.new()
		if config.load("user://language.cfg") == OK:
			initial = str(config.get_value("language", "locale", "en"))
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lang="):
			initial = argument.trim_prefix("--lang=")
	_build_selector()
	set_locale(initial, false)


func normalise(value: String) -> String:
	var code := value.replace("-", "_").to_lower()
	if code.begins_with("ar"):
		return "ar"
	if code.begins_with("vi"):
		return "vi"
	if code.begins_with("yue") or code in ["zh_hk", "zh_tw", "zh_hant", "zh_hant_hk"]:
		return "zh_HK"
	if code.begins_with("zh"):
		return "zh_CN"
	return "en"


func set_locale(value: String, notify_parent: bool = true) -> void:
	locale = normalise(value)
	TranslationServer.set_locale(locale)
	selector.select(LOCALES.find(locale))
	selector.tooltip_text = tr("Language")
	_refresh_formatted(get_tree().root)
	locale_changed.emit()
	if OS.has_feature("web"):
		var web_code := locale.replace("_", "-")
		JavaScriptBridge.eval("try { localStorage.setItem('screening-game-language', '%s'); } catch (_) {}" % web_code)
		if notify_parent:
			JavaScriptBridge.eval("window.parent.postMessage({type:'screening-language-changed', language:'%s'}, location.origin)" % web_code)
	else:
		var config := ConfigFile.new()
		config.set_value("language", "locale", locale)
		config.save("user://language.cfg")


func _on_browser_language(arguments: Array) -> void:
	if not arguments.is_empty():
		set_locale(str(arguments[0]), false)


func _build_selector() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	selector = OptionButton.new()
	selector.position = Vector2(10, 10)
	selector.size = Vector2(252, 30)
	selector.add_theme_font_size_override("font_size", 18)
	selector.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	selector.layout_direction = Control.LAYOUT_DIRECTION_LTR
	for language_name in NAMES:
		selector.add_item(language_name)
	selector.item_selected.connect(func(index: int) -> void:
		set_locale(LOCALES[index])
		selector.release_focus()
	)
	layer.add_child(selector)
	# Arrow keys remain gameplay controls until the language menu is explicitly opened.
	selector.focus_mode = Control.FOCUS_CLICK


func bind_text(control: Control, source: String, arguments: Array = [], property: String = "text") -> void:
	control.set_meta("localized_" + property, [source, arguments])
	_apply_formatted(control, property)


func _apply_formatted(control: Control, property: String) -> void:
	var binding: Array = control.get_meta("localized_" + property)
	var translated_args: Array = []
	for argument in binding[1]:
		translated_args.append(tr(argument) if argument is String else argument)
	control.set(property, tr(binding[0]) % translated_args if not translated_args.is_empty() else tr(binding[0]))


func _refresh_formatted(node: Node) -> void:
	if node is Control:
		for property in ["text", "tooltip_text"]:
			if node.has_meta("localized_" + property):
				_apply_formatted(node, property)
	for child in node.get_children():
		_refresh_formatted(child)
