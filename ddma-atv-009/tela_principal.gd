extends Control

@onready var progress_bar = $CenterContainer/NinePatchRect/MarginContainer/VBoxContainer/ProgressBar

func _on_button_pressed() -> void:
	progress_bar.value = 0
	var tween = create_tween()
	tween.tween_property(progress_bar,"value", 100, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	pass # Replace with function body.
