extends Control

@onready var i = $TextEdit

func _on_button_pressed() -> void:
	var data := Marshalls.base64_to_raw(i.text)
	
	var buf := DataBuffer.new()
	buf.begin_packet_read(data)
	
	var sim := Simulation.new()
	sim.deserialize(buf, data.size())
	
	sim.print_state()
	
