extends CanvasLayer

func _on_resume_pressed() -> void:
	Global.main.pause_menu()


func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
