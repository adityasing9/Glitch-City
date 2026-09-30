class_name ObservableObject
extends Node3D

signal observation_changed(is_observed: bool, by_player: bool, by_camera: bool)

enum State {
    NORMAL,
    OBSERVED,
    UNOBSERVED,
    GLITCHED,
    CHANGED
}

@export var object_name: String = "Observable Object"
@export var observation_radius: float = 2.0
@export var current_state: State = State.NORMAL

var is_observed: bool = false
var is_observed_by_player: bool = false
var is_observed_by_camera: bool = false

var time_unobserved: float = 0.0
var time_observed: float = 0.0

func _ready() -> void:
    add_to_group("observable_objects")
    _init_observable()

func _init_observable() -> void:
    pass

func get_observation_points() -> Array[Vector3]:
    # Default to global origin + offsets around center
    var pts: Array[Vector3] = []
    pts.append(global_position)
    pts.append(global_position + Vector3(0, 0.8, 0))
    pts.append(global_position + Vector3(0, -0.5, 0))
    pts.append(global_position + Vector3(0.5, 0, 0))
    pts.append(global_position + Vector3(-0.5, 0, 0))
    return pts

func update_observation_state(observed_by_player: bool, observed_by_camera: bool, delta: float) -> void:
    var now_observed = observed_by_player or observed_by_camera
    var was_observed = is_observed
    
    is_observed_by_player = observed_by_player
    is_observed_by_camera = observed_by_camera
    is_observed = now_observed
    
    if now_observed:
        time_observed += delta
        time_unobserved = 0.0
        if not was_observed:
            _on_became_observed()
        _process_observed(delta)
    else:
        time_unobserved += delta
        time_observed = 0.0
        if was_observed:
            _on_became_unobserved()
        _process_unobserved(delta)
    
    if was_observed != now_observed:
        emit_signal("observation_changed", now_observed, observed_by_player, observed_by_camera)

func _on_became_observed() -> void:
    current_state = State.OBSERVED

func _on_became_unobserved() -> void:
    current_state = State.UNOBSERVED

func _process_observed(_delta: float) -> void:
    pass

func _process_unobserved(_delta: float) -> void:
    pass
