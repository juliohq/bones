extends "res://ui/ui.gd"


export var blink_paused_label: bool = true
# Time between turning label from white to transparent and vice-versa
export var paused_label_blink_delay: float = 1.0

onready var paused_label: Label = $Margin/VBox/PausedLabel


func _ready() -> void:
	if blink_paused_label:
		blink_paused_label()


func blink_paused_label() -> void:
	match paused_label.modulate:
		Color.white:
			paused_label.modulate = Color.transparent
		Color.transparent:
			paused_label.modulate = Color.white
	yield(get_tree().create_timer(paused_label_blink_delay), "timeout")
	blink_paused_label()


func _on_Resume_pressed():
	pass # Replace with function body.


func _on_Options_pressed():
	pass # Replace with function body.


func _on_Quit_pressed():
	pass # Replace with function body.
