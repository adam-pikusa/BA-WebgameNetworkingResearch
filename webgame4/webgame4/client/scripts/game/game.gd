extends Node3D

@export var error_label: Label
@export var delta_label: Label
@export var entity_pool: EntityPool

func _ready() -> void:
	State.game.ctx.space = get_world_3d().direct_space_state

func _physics_process(delta: float) -> void:
	State.game.tick_interp = 0

	var input_sample := 0
	
	if State.game.cur_cam != null and not State.game.block_movement:
		input_sample = InputHelper.sample_input_data(
			State.game.cur_cam.input_yaw(), 
			State.game.cur_cam.input_pitch())

	State.client.update(State.game, input_sample)

func _process(delta: float) -> void:
	#error_label.text = str(err_buf.get_avg())
	delta_label.text = str(State.client.client_tick - State.game.h.sim().state_tick)
	State.game.tick_interp += delta * 30.0
	
	entity_pool.reset()
	for e_index in State.game.h.sim().entities.size():
		var e = State.game.h.sim().entities[e_index]
		var entity: Entity = entity_pool.get_next(e.type)
		entity.set_state(e)
	entity_pool.end()
