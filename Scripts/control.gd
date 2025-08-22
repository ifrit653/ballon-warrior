extends Control

func show_text(text: String, start_pos: Vector2):
	# Set up the label
	$Label.text = text
	position = start_pos
	
	# Simple animation - move up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move upward
	tween.tween_property(self, "position:y", position.y - 100, 2.0)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	
	# Delete after 2 seconds
	await tween.finished
	queue_free()
