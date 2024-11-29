class_name EntityPool extends Node3D

class Pool:
	var container: Node3D
	var scene: PackedScene
	var next := 0
	var entities: Array[Entity] = []
	
	func _init(container: Node3D, scene: PackedScene, init_size: int) -> void:
		self.container = container
		self.scene = scene
		for i in init_size:
			var ni := scene.instantiate()
			entities.append(ni)
			container.add_child(ni)
	
	func reset() -> void:
		next = 0
	
	func get_next() -> Entity:
		if next == entities.size():
			entities.append(scene.instantiate())
		next += 1
		return entities[next - 1]
	
	func end() -> void:
		while next < entities.size():
			entities[next].deactivate()
			next += 1

var pools: Dictionary

func _ready() -> void:
	pools = { 
		Sim_Human.type: Pool.new(self, preload("res://client/scenes/game/human.tscn"), 5),
		Sim_Box  .type: Pool.new(self, preload("res://client/scenes/game/box.tscn"  ), 5),
		Sim_Item .type: Pool.new(self, preload("res://client/scenes/game/item.tscn" ), 10)
	}

	print("created entity pools:")
	print(pools)

func reset() -> void:
	for pool: Pool in pools.values(): pool.reset()

func get_next(entity_type: int) -> Entity:
	return pools[entity_type].get_next()
	
func end() -> void:
	for pool: Pool in pools.values(): pool.end()
	
	
