extends CanvasLayer

func _on_restart_button_pressed() -> void:
	print("Debug message: Pressed restart button")
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("Debug message: Scene reset")
	visible = false

func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
