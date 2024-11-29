class_name Box extends Entity

func deactivate() -> void:
	visible = false

func set_state(s: Sim_Entity) -> void:
	var b := s as Sim_Box
	visible = true
	position = b.position_last.lerp(b.position, State.game.tick_interp)
