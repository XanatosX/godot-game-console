class_name ConsoleOutput extends RichTextLabel

var _stored_text: String = ""

func _ready() -> void:
	bbcode_enabled = true
	meta_clicked.connect(_scroll_down)

func append_bbcode_text(text: String) -> void:
	append_text(text)
	_stored_text += text

func get_stored_text() -> String:
	return _stored_text

func clear_stored_text():
	_stored_text = ""
	clear()

func _scroll_down(_data):
	scroll_to_line(get_line_count() - 1)
