class_name ObservableDoor
extends ObservableObject

signal door_opened

@export var is_unlocked: bool = false
@export var is_open: bool = false

var door_body: StaticBody3D
var left_leaf: MeshInstance3D
var right_leaf: MeshInstance3D
var status_light: OmniLight3D
var door_mat: StandardMaterial3D

func _init_observable() -> void:
    object_name = "Security Gate 07"
    _setup_door()

func _setup_door() -> void:
    door_body = StaticBody3D.new()
    door_body.collision_layer = 1
    door_body.collision_mask = 0
    add_child(door_body)
    
    var col = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(4.0, 4.5, 0.6)
    col.shape = box
    col.position = Vector3(0, 2.25, 0)
    door_body.add_child(col)
    
    door_mat = StandardMaterial3D.new()
    door_mat.albedo_color = Color(0.12, 0.14, 0.18)
    door_mat.metallic = 0.8
    door_mat.roughness = 0.3
    
    # Left Leaf
    left_leaf = MeshInstance3D.new()
    var l_mesh = BoxMesh.new()
    l_mesh.size = Vector3(2.0, 4.5, 0.4)
    left_leaf.mesh = l_mesh
    left_leaf.position = Vector3(-1.0, 2.25, 0)
    left_leaf.material_override = door_mat
    add_child(left_leaf)
    
    # Right Leaf
    right_leaf = MeshInstance3D.new()
    var r_mesh = BoxMesh.new()
    r_mesh.size = Vector3(2.0, 4.5, 0.4)
    right_leaf.mesh = r_mesh
    right_leaf.position = Vector3(1.0, 2.25, 0)
    right_leaf.material_override = door_mat
    add_child(right_leaf)
    
    # Status Light
    status_light = OmniLight3D.new()
    status_light.position = Vector3(0, 4.2, 0.6)
    status_light.light_color = Color(1.0, 0.15, 0.15)
    status_light.light_energy = 1.2
    status_light.omni_range = 4.0
    add_child(status_light)

func unlock_door() -> void:
    is_unlocked = true
    if status_light:
        status_light.light_color = Color(1.0, 0.8, 0.1) # Amber waiting

func _on_became_unobserved() -> void:
    super._on_became_unobserved()
    # If unlocked and unobserved, reality shifts the door open!
    if is_unlocked and not is_open:
        _perform_reality_shift()

func _perform_reality_shift() -> void:
    is_open = true
    current_state = State.CHANGED
    
    # Open leaves
    if left_leaf:
        left_leaf.position.x = -2.8
    if right_leaf:
        right_leaf.position.x = 2.8
    if door_body:
        door_body.process_mode = Node.PROCESS_MODE_DISABLED
    if status_light:
        status_light.light_color = Color(0.1, 1.0, 0.4)
        
    emit_signal("door_opened")
    if AudioManager.instance:
        AudioManager.instance.play_glitch()
