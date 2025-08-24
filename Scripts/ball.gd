extends RigidBody2D

var pos: Vector2
var rota: float
var dir: float
var speed= 500

func _ready() -> void:
	global_position=pos
	global_rotation=rota
