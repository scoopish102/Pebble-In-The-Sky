class_name ChoiceNotification extends Notification

@export var choiceTitle : RichTextLabel
@export var confirmButton : Button
@export var cancelButton : Button
	
func setChoices(_choiceText: String = ""):
	self.choiceTitle.text = _choiceText

func getChoice() -> bool:
	return await result

func yesPressed():
	result.emit(true)
	queue_free()

func noPressed():
	result.emit(false)
	queue_free()
