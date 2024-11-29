class_name InputHelper

const MOVE_FWD   := 1 << 32 + 0
const MOVE_RIGHT := 1 << 32 + 1
const MOVE_BACK  := 1 << 32 + 2
const MOVE_LEFT  := 1 << 32 + 3

const ACTION1 := 1 << 32 + 4 + 0
const ACTION2 := 1 << 32 + 4 + 1

const INTERACT_Q := 1 << 32 + 4 + 2 + 0
const INTERACT_E := 1 << 32 + 4 + 2 + 1
const INTERACT_R := 1 << 32 + 4 + 2 + 2
const INTERACT_F := 1 << 32 + 4 + 2 + 3
const INTERACT_G := 1 << 32 + 4 + 2 + 4
const INTERACT_T := 1 << 32 + 4 + 2 + 5

static func sample_input_data(look_input_yaw: float, look_input_pitch: float) -> int:
	var result := 0 
	
	result |= DataBuffer.quantize_angle16(look_input_yaw)
	result |= DataBuffer.quantize_angle16(look_input_pitch) << 16
	
	if Input.is_action_pressed("move_fwd"  ): result |= MOVE_FWD
	if Input.is_action_pressed("move_right"): result |= MOVE_RIGHT
	if Input.is_action_pressed("move_back" ): result |= MOVE_BACK
	if Input.is_action_pressed("move_left" ): result |= MOVE_LEFT
	
	if Input.is_action_pressed("action1"): result |= ACTION1
	if Input.is_action_pressed("action2"): result |= ACTION2
	
	if Input.is_action_pressed("interact_q"): result |= INTERACT_Q
	if Input.is_action_pressed("interact_e"): result |= INTERACT_E
	if Input.is_action_pressed("interact_r"): result |= INTERACT_R
	if Input.is_action_pressed("interact_f"): result |= INTERACT_F
	if Input.is_action_pressed("interact_g"): result |= INTERACT_G
	if Input.is_action_pressed("interact_t"): result |= INTERACT_T
	
	return result
	
static func get_move_dir_vector3(input_data: int) -> Vector3:
	var result := Vector3()
	if input_data & MOVE_FWD  : result += Vector3.FORWARD
	if input_data & MOVE_RIGHT: result += Vector3.RIGHT
	if input_data & MOVE_BACK : result += Vector3.BACK
	if input_data & MOVE_LEFT : result += Vector3.LEFT
	return result

static func move_fwd  (input_data: int) -> bool: return input_data & MOVE_FWD   != 0
static func move_right(input_data: int) -> bool: return input_data & MOVE_RIGHT != 0
static func move_back (input_data: int) -> bool: return input_data & MOVE_BACK  != 0
static func move_left (input_data: int) -> bool: return input_data & MOVE_LEFT  != 0

static func action1(input_data: int) -> bool: return input_data & ACTION1 != 0
static func action2(input_data: int) -> bool: return input_data & ACTION2 != 0

static func interact_q(input_data: int) -> bool: return input_data & INTERACT_Q != 0
static func interact_e(input_data: int) -> bool: return input_data & INTERACT_E != 0
static func interact_r(input_data: int) -> bool: return input_data & INTERACT_R != 0
static func interact_f(input_data: int) -> bool: return input_data & INTERACT_F != 0
static func interact_g(input_data: int) -> bool: return input_data & INTERACT_G != 0
static func interact_t(input_data: int) -> bool: return input_data & INTERACT_T != 0

static func get_look_input_yaw(input_data: int) -> float:
	return DataBuffer.quantized_angle16(input_data & 0xFFFF)

static func get_look_input_pitch(input_data: int) -> float:
	return DataBuffer.quantized_angle16((input_data >> 16) & 0xFFFF)

static func deser(buf: DataBuffer) -> int:
	return buf.i64()

static func ser(buf: DataBuffer, input_data: int) -> void:
	buf.i64(input_data)
