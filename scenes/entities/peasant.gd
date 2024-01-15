extends CharacterBody3D
class_name Peasant

@onready var character_movement_3d: CharacterMovement3D = $CharacterMovement3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart

var _current_burning_entity: BurnableEntity = null

func _physics_process(delta: float) -> void:
	pass
	#if (_current_burning_entity and !_current_burning_entity.being_serviced): return
	
func _on_looking_state_physics_processing(delta: float) -> void:
	if (get_tree().get_nodes_in_group("burning").is_empty()): return # TODO: Pick random point instead
	
	var closest_entity = _get_closest_burning_entity()
	if (closest_entity.is_equal_approx(Vector3.ZERO)): return
	
	navigation_agent_3d.target_position = closest_entity
	state_chart.send_event("look_to_pursue")
	
func _get_closest_burning_entity():
	var burning_entites := get_tree().get_nodes_in_group("burning")
	var closest_distance = 10000.0
	var closest_entity_pos = Vector3.ZERO
	
	for entity: BurnableEntity in burning_entites:
		if (entity.being_serviced): continue
		
		var pos = global_position.distance_squared_to(entity.global_position)
		if (pos < closest_distance):
			_current_burning_entity = entity
			closest_entity_pos = entity.global_position
	
	return closest_entity_pos


func _on_pursuing_state_physics_processing(delta: float) -> void:
	if (_current_burning_entity.being_serviced): state_chart.send_event("pursue_to_look")
	
	character_movement_3d.move_to_direction(navigation_agent_3d.get_next_path_position() - global_position, delta)


func _on_navigation_agent_3d_target_reached() -> void:
	state_chart.send_event("pursue_to_watering")
	_current_burning_entity.being_serviced = true
