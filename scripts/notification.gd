class_name Notification extends VBoxContainer

@export var title : RichTextLabel
@export var exitButton : Button
@export var content : RichTextLabel

static var sampleText := "Come, let us build ourselves a city, with a tower that reaches to the heavens, so that we may make a name for ourselves."
signal result(result: bool)

func setContent(_title: String, _text: String):
	self.title.text = _title
	self.content.text = _text

func exitButtonPressed():
	result.emit(false)
	self.queue_free()

func centerOnScreen():
	self.position.x = Global.screenSize.x/2 - self.size.x/2
	self.position.y = Global.screenSize.y/2 - self.size.y/2
