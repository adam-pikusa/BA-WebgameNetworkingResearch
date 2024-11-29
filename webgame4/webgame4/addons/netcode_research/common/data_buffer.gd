class_name DataBuffer

var _buf: PackedByteArray
var _cursor := 0

var _recv_buf: PackedByteArray
var _write_mode := true

static func quantize_angle8(angle: float) -> int:
	while angle < 0: angle += TAU
	while angle > TAU: angle -= TAU
	return int(angle / TAU * 0xFF) & 0xFF

static func quantized_angle8(input: int) -> float:
	return float(input) / float(0xFF) * TAU

static func quantize_angle16(angle: float) -> int:
	while angle < 0: angle += TAU
	while angle > TAU: angle -= TAU
	return int(angle / TAU * 0xFFFF) & 0xFFFF
	
static func quantized_angle16(input: int) -> float:
	return float(input) / float(0xFFFF) * TAU

func _init():
	_buf.resize(2048)

func begin_packet_write():
	_write_mode = true
	_cursor = 0
	
func begin_packet_read(recv_buf: PackedByteArray):
	_write_mode = false
	_recv_buf = recv_buf
	_cursor = 0
	
func i8(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_s8(_cursor, val)
	else: result = _recv_buf.decode_s8(_cursor)
	_cursor += 1
	return result
	
func u8(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_u8(_cursor, val)
	else: result = _recv_buf.decode_u8(_cursor)
	_cursor += 1
	return result

func insert_u8(pos: int, val: int) -> void:
	_buf[pos] = val

func i16(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_s16(_cursor, val)
	else: result = _recv_buf.decode_s16(_cursor)
	_cursor += 2
	return result

func u16(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_u16(_cursor, val)
	else: result = _recv_buf.decode_u16(_cursor)
	_cursor += 2
	return result

func u32(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_u32(_cursor, val)
	else: result = _recv_buf.decode_u32(_cursor)
	_cursor += 4
	return result

func insert_u32(pos: int, val: int) -> void:
	_buf.encode_u32(pos, val)

func i64(val: int = 0) -> int:
	var result := 0
	if _write_mode: _buf.encode_s64(_cursor, val)
	else: result = _recv_buf.decode_s64(_cursor)
	_cursor += 8
	return result

func f16(val: float = 0) -> float:
	var result := 0.0
	if _write_mode: _buf.encode_half(_cursor, val)
	else: result = _recv_buf.decode_half(_cursor)
	_cursor += 2
	return result

func f32(val: float = 0) -> float:
	var result := 0.0
	if _write_mode: _buf.encode_float(_cursor, val)
	else: result = _recv_buf.decode_float(_cursor)
	_cursor += 4
	return result

func vec2_i16(val: Vector2i = Vector2i()) -> Vector2i:
	var result_x := 0
	var result_y := 0
	
	if _write_mode: _buf.encode_s16(_cursor, val.x)
	else: result_x = _recv_buf.decode_s16(_cursor)
	_cursor += 2
	
	if _write_mode: _buf.encode_s16(_cursor, val.y) 
	else: result_y = _recv_buf.decode_s16(_cursor)
	_cursor += 2
	
	return Vector2i(result_x, result_y)

func vec2_f16(val: Vector2 = Vector2()) -> Vector2:
	var result_x: float = 0
	var result_y: float = 0
	
	if _write_mode: _buf.encode_half(_cursor, val.x)
	else: result_x = _recv_buf.decode_half(_cursor)
	_cursor += 2
	
	if _write_mode: _buf.encode_half(_cursor, val.y) 
	else: result_y = _recv_buf.decode_half(_cursor)
	_cursor += 2
	
	return Vector2(result_x, result_y)

func vec2_f32(val: Vector2 = Vector2()) -> Vector2:
	var result_x: float = 0
	var result_y: float = 0
	
	if _write_mode: _buf.encode_float(_cursor, val.x)
	else: result_x = _recv_buf.decode_float(_cursor)
	_cursor += 4
	
	if _write_mode: _buf.encode_float(_cursor, val.y) 
	else: result_y = _recv_buf.decode_float(_cursor)
	_cursor += 4
	
	return Vector2(result_x, result_y)

func vec3_f32(val: Vector3 = Vector3()) -> Vector3:
	var result_x: float = 0
	var result_y: float = 0
	var result_z: float = 0
	
	if _write_mode: _buf.encode_float(_cursor, val.x)
	else: result_x = _recv_buf.decode_float(_cursor)
	_cursor += 4
	
	if _write_mode: _buf.encode_float(_cursor, val.y) 
	else: result_y = _recv_buf.decode_float(_cursor)
	_cursor += 4
	
	if _write_mode: _buf.encode_float(_cursor, val.z) 
	else: result_z = _recv_buf.decode_float(_cursor)
	_cursor += 4
	
	return Vector3(result_x, result_y, result_z)

func copy_from_recv_buffer(other_buf: DataBuffer, amount: int) -> void:
	for i: int in amount:
		_buf[_cursor] = other_buf._recv_buf[other_buf._cursor + i]
		_cursor += 1

func copy_from_beginning_write_buffer(other_buf: DataBuffer) -> void:
	for i: int in other_buf._cursor:
		_buf[_cursor] = other_buf._buf[i]
		_cursor += 1

func copy_from_beginning_recv_buffer(other_buf: DataBuffer) -> void:
	for i: int in other_buf._cursor:
		_buf[_cursor] = other_buf._recv_buf[i]
		_cursor += 1

func advance(amount: int) -> void:
	_cursor += amount

func get_buf() -> PackedByteArray: 
	return _buf.slice(0, _cursor)

func bytes_read() -> int: return _cursor
func bytes_written() -> int: return _cursor

func bytes_remaining() -> int: return _recv_buf.size() - _cursor
