class_name Item extends Entity

func deactivate() -> void:
	visible = false

func set_state(s: Sim_Entity) -> void:
	visible = true
	position = s.position
