extends Node


signal paused
signal resumed


func _ready() -> void:
    set_pause_mode(Node.PAUSE_MODE_PROCESS)


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if get_tree().paused:
            resume()


func pause() -> void:
    get_tree().paused = true
    emit_signal("paused")


func resume() -> void:
    get_tree().paused = false
    emit_signal("resumed")
