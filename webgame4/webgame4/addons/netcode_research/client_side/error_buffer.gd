class_name ErrorBuffer

const SIZE := 30 * 5
const SIZE_INV := 1.0 / SIZE

var _buf: PackedInt32Array
var _next := 0

func _init() -> void:
	_buf.resize(SIZE)

func add(val: int) -> void:
	_buf[_next % SIZE] = val
	_next += 1
	
func get_avg() -> float:
	var error_sum := 0
	for e: int in _buf:
		error_sum += e
	return error_sum * SIZE_INV
