class_name QuantumPlatform
extends ObservableObject

@export var move_distance: float = 6.0
@export var move_speed: float = 3.5

var platform_body: AnimatableBody3D
var platform_mesh: MeshInstance3D
var holo_mat: StandardMaterial3D
var light: OmniLight3D

var base_y: float = 0.0
var target_y: float = 0.0
var current_y: float = 0.0
var is_player_on_platform: bool = false
var going_up: bool = true

func _init_observable() -> void:
    object_name = "Quantum Kinetic Lift"
    _setup_platform()

func _setup_platform() -> void:
    base_y = position.y
    target_y = base_y + move_distance
    current_y = base_y
    
    platform_body = AnimatableBody3D.new()
    platform_body.collision_layer = 1
    platform_body.sync_to_physics = true
    add_child(platform_body)
    
    var col = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(3.2, 0.4, 3.2)
    col.shape = box
    platform_body.add_child(col)
    
    platform_mesh = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(3.2, 0.4, 3.2)
    platform_mesh.mesh = b_mesh
    
    holo_mat = StandardMaterial3D.new()
    holo_mat.albedo_color = Color(0.1, 0.15, 0.22)
    holo_mat.metallic = 0.8
    holo_mat.roughness = 0.3
    holo_mat.emission_enabled = true
    holo_mat.emission = Color(0.1, 0.8, 1.0)
    holo_mat.emission_energy_multiplier = 0.5
    platform_mesh.material_override = holo_mat
    platform_body.add_child(platform_mesh)
    
    # Glowing trim
    var trim = MeshInstance3D.new()
    var t_mesh = BoxMesh.new()
    t_mesh.size = Vector3(3.25, 0.1, 3.25)
    trim.mesh = t_mesh
    trim.position = Vector3(0, 0.18, 0)
    var trim_mat = StandardMaterial3D.new()
    trim_mat.albedo_color = Color(0.1, 0.9, 1.0)
    trim_mat.emission_enabled = true
    trim_mat.emission = Color(0.1, 0.9, 1.0)
    trim_mat.emission_energy_multiplier = 2.0
    trim.material_override = trim_mat
    platform_body.add_child(trim)
    
    # Detection area to check if player is standing on it
    var area = Area3D.new()
    var a_col = CollisionShape3D.new()
    var a_box = BoxShape3D.new()
    a_box.size = Vector3(3.0, 1.5, 3.0)
    a_col.shape = a_box
    a_col.position = Vector3(0, 1.0, 0)
    area.add_child(a_col)
    area.body_entered.connect(_on_body_entered)
    area.body_exited.connect(_on_body_exited)
    platform_body.add_child(area)
    
    light = OmniLight3D.new()
    light.position = Vector3(0, 0.5, 0)
    light.light_color = Color(0.1, 0.85, 1.0)
    light.light_energy = 1.0
    light.omni_range = 4.0
    platform_body.add_child(light)

func _on_body_entered(body: Node) -> void:
    if body is Player:
        is_player_on_platform = true

func _on_body_exited(body: Node) -> void:
    if body is Player:
        is_player_on_platform = false

func get_observation_points() -> Array[Vector3]:
    var pts: Array[Vector3] = []
    if platform_body:
        pts.append(platform_body.global_position)
        pts.append(platform_body.global_position + Vector3(1.2, 0.2, 0))
        pts.append(platform_body.global_position + Vector3(-1.2, 0.2, 0))
    else:
        pts.append(global_position)
    return pts

func _physics_process(delta: float) -> void:
    # Core mechanic: ONLY moves when UNOBSERVED!
    if not is_observed:
        # Unobserved: Reality shifts position!
        var dest_y = target_y if going_up else base_y
        current_y = move_toward(current_y, dest_y, delta * move_speed)
        platform_body.position.y = current_y - base_y
        
        if abs(current_y - dest_y) < 0.05:
            # Reached end: toggle direction for next cycle
            going_up = not going_up
            
        if holo_mat:
            holo_mat.emission = Color(1.0, 0.3, 0.1) # Amber while actively shifting in the dark
    else:
        # Observed: Wave function collapsed! Platform freezes solid!
        if holo_mat:
            holo_mat.emission = Color(0.1, 0.9, 1.0) # Steady cyan frozen
