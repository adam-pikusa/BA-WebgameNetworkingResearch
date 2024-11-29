class_name Sim_Entity

var remove := false

func clone() -> Sim_Entity: return null
func update1(ctx: Context, input_frame: Dictionary) -> void: pass
func update2(ctx: Context, input_frame: Dictionary) -> void: pass
func ser(buf: DataBuffer) -> void: pass
func print_state() -> void: pass
	
static func deser(buf: DataBuffer) -> Sim_Entity: 
	var ent_type := buf.u8() 
	match ent_type:
		Sim_Human.type: return Sim_Human.deser(buf)
		Sim_Box.type: return Sim_Box.deser(buf)
		Sim_Item.type: return Sim_Item.deser(buf)

	assert(false, "failed to deserialize ent_type:" + str(ent_type))
	return null
