# Platform.gd
extends StaticBody2D
class_name Platform

enum PlatformType {
	NORMAL,
	WIDE,
	NARROW,
	BREAKABLE
}

@export var platform_type: PlatformType = PlatformType.NORMAL
var platform_width: float = 128.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var tileset_texture = preload("res://Assets/Tiles_pack/Tileset_1.png")

func _ready():
	sprite.texture = tileset_texture
	sprite.region_enabled = true
	setup_platform()

func setup_platform():
	match platform_type:
		PlatformType.NORMAL:
			_setup_normal()
		PlatformType.WIDE:
			_setup_wide()
		PlatformType.NARROW:
			_setup_narrow()
		PlatformType.BREAKABLE:
			_setup_breakable()

func _setup_normal():
	platform_width = 128.0  # BIGGER
	sprite.region_rect = Rect2(0, 0, 32, 32)
	sprite.scale = Vector2(4, 2)  # MUCH BIGGER scaling
	_setup_collision()

func _setup_wide():
	platform_width = 192.0  # BIGGER
	sprite.region_rect = Rect2(32, 0, 32, 32)
	sprite.scale = Vector2(6, 2)  # MUCH BIGGER scaling
	_setup_collision()

func _setup_narrow():
	platform_width = 96.0   # BIGGER
	sprite.region_rect = Rect2(64, 0, 32, 32)
	sprite.scale = Vector2(3, 2)  # BIGGER scaling
	_setup_collision()

func _setup_breakable():
	platform_width = 128.0  # BIGGER
	sprite.region_rect = Rect2(96, 0, 32, 32)
	sprite.scale = Vector2(4, 2)  # BIGGER scaling
	sprite.modulate = Color.RED  # Visual indicator it's breakable
	_setup_collision()

func _setup_collision():
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(platform_width, 64)  # BIGGER height too
	collision.shape = rect_shape
