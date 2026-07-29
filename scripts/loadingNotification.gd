class_name LoadingNotification extends SingleOptionNotification

@export var progressBar : ProgressBar

#static var sampleText := "Come, let us build ourselves a city, with a tower that reaches to the heavens, so that we may make a name for ourselves."
#signal result(result: bool)

func _ready():
	self.optionButton.disabled = true
	self.exitButton.disabled = true
	Event.updateProgressBar.connect(updateProgressBar)

func setOption(option: String = "Okay"):
	self.optionButton.text = option

func exitButtonPressed():
	result.emit(false)
	self.queue_free()

func confirmButtonPressed():
	result.emit(true)
	self.queue_free()

func _on_progress_bar_value_changed(value):
	if progressBar.value >= progressBar.max_value:
		self.optionButton.disabled = false

func updateProgressBar(percent):
	progressBar.value = progressBar.max_value * percent
	#print(percent)
