class_name Human extends Entity

@export var neck: Node3D
@export var cam: Cam
@export var name_label: WorldLabel

func deactivate() -> void:
	visible = false
	name_label.hidden = true

func set_state(s: Sim_Entity) -> void:
	var h := s as Sim_Human
	
	if s.bound_to_input != State.client.this_id: 
		visible = true
		name_label.hidden = false
		name_label.set_text(State.client.get_client_name(h.bound_to_input))
		position = h.position_last.lerp(h.position, State.game.tick_interp)
		neck.rotation.y = h.look_yaw
		neck.rotation.x = h.look_pitch
		return
	
	visible = false
	name_label.hidden = true
	State.game.set_cam(cam)
	
	var predicted_state := h.clone()
	var predict_tick := (State.game as GameState).h.sim().state_tick
	var input_to_predict: int
	
	while predict_tick < State.client.client_tick:
		input_to_predict = State.client.p_buffer.get_input(predict_tick)
		predict_tick += 1
	
		predicted_state.move(State.game.ctx, input_to_predict)
	
	position = predicted_state.position_last.lerp(predicted_state.position, State.game.tick_interp)
	
	
	State.game.cur_cam.moving = 1.0 if InputHelper.get_move_dir_vector3(input_to_predict) != Vector3.ZERO else 0.0
	
	if InputHelper.move_left (input_to_predict): State.game.cur_cam.tilt =  .7
	if InputHelper.move_right(input_to_predict): State.game.cur_cam.tilt = -.7
	
	State.game.cur_cam.cursor = InputHelper.action2(input_to_predict)
