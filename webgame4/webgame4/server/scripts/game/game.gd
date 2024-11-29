extends Node3D

func _ready() -> void:	
	var box_positions: Array[Vector3] = []
	var item_positions: Array[Vector3] = []
	
	for box_pos: Marker3D in $Town/BoxPositions.get_children():
		box_positions.append(box_pos.position)
	
	for item_pos: Marker3D in $Town/ItemPositions.get_children():
		item_positions.append(item_pos.position)
		
	State.game = ServerGameState.new()
		
	State.game.sim.init_base_game_state(box_positions, item_positions)
	
	print("init game state size:", (State.game.sim as Simulation).get_serialized_size())
	
	State.game.ctx.space = get_world_3d().direct_space_state


func _physics_process(delta: float) -> void:
	State.server.update(State.game)
