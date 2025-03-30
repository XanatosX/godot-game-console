class_name ConsoleOutput extends RichTextLabel

var stored_text: String = ""

func append_bbcode_text(text: String):
	append_text(text)
	stored_text += text

func get_stored_text() -> String:
	return stored_text

func clear_stored_text():
	stored_text = ""
	clear()