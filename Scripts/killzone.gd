extends Area2D

@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var bg_music: AudioStreamPlayer = $"../bg_music"


func _on_body_entered(body: Node2D) -> void:
	timer.start()
	bg_music.stop()
	audio_stream_player.play()
	await get_tree().create_timer(0.5).timeout

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
