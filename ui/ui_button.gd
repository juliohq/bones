extends Button


export var mouse_entered_sound: AudioStream


func _ready():
	pass


func _on_UIButton_mouse_entered():
	if mouse_entered_sound:
		SFX.play(mouse_entered_sound)


func _on_UIButton_mouse_exited():
	pass # Replace with function body.
