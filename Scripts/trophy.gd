extends Area2D

#reference to the root node 
@onready var player = get_node("%Player")
@onready var game_manager = %GameManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_trophy_touched(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Player"):
		game_manager.trigger_stage_clear()
		print("victory")
		queue_free()  # example action
