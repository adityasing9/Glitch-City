class_name ObservableBridge
extends ObservableObject

@export var length: float = 12.0
@export var width: float = 3.2
@export var stability_speed: float = 4.0

var collision_body: StaticBody3D
var mesh_instance: MeshInstance3D
var bridge_material: ShaderMaterial
var omni_light: OmniLight3D

var stability: float = 1.0
var target_stability: float = 1.0

func _init_observable() -> void:
    object_name = "Quantum Lattice Bridge"
    _setup_nodes()

func _setup_nodes() -> void:
    # Setup StaticBody3D & Collision
    collision_body = StaticBody3D.new()
    collision_body.collision_layer = 1
    collision_body.collision_mask = 0
    add_child(collision_body)
    
    var col_shape = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(width, 0.4, length)
    col_shape.shape = box
    col_shape.position = Vector3(0, -0.2, 0)
    collision_body.add_child(col_shape)
    
    # Setup MeshInstance3D
    mesh_instance = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(width, 0.35, length)
    mesh_instance.mesh = box_mesh
    mesh_instance.position = Vector3(0, -0.175, 0)
    add_child(mesh_instance)
    
    # Setup Shader Material
    var shader = load("res://shaders/hologram_bridge.gdshader")
    bridge_material = ShaderMaterial.new()
    bridge_material.shader = shader
    bridge_material.set_shader_parameter("base_color", Color(0.1, 0.85, 1.0, 0.85))
    bridge_material.set_shader_parameter("glitch_color", Color(1.0, 0.2, 0.25, 0.6))
    bridge_material.set_shader_parameter("stability", 1.0)
    mesh_instance.material_override = bridge_material
    
    # Side guard rails (hologram markers)
    _create_rail(Vector3(-width * 0.5, 0.2, 0))
    _create_rail(Vector3(width * 0.5, 0.2, 0))
    
    # Ambient Light
    omni_light = OmniLight3D.new()
    omni_light.light_color = Color(0.1, 0.85, 1.0)
    omni_light.light_energy = 1.5
    omni_light.omni_range = 8.0
    add_child(omni_light)

func _create_rail(pos: Vector3) -> void:
    var rail = MeshInstance3D.new()
    var rail_mesh = BoxMesh.new()
    rail_mesh.size = Vector3(0.15, 0.4, length)
    rail.mesh = rail_mesh
    rail.position = pos
    rail.material_override = bridge_material
    add_child(rail)

func get_observation_points() -> Array[Vector3]:
    var pts: Array[Vector3] = []
    # Key anchor points along the bridge span
    pts.append(global_position + Vector3(0, 0.3, -length * 0.4))
    pts.append(global_position + Vector3(0, 0.3, 0.0))
    pts.append(global_position + Vector3(0, 0.3, length * 0.4))
    return pts

func _process(delta: float) -> void:
    if is_observed:
        target_stability = 1.0
    else:
        target_stability = 0.0
        
    stability = move_toward(stability, target_stability, delta * stability_speed)
    
    if bridge_material:
        bridge_material.set_shader_parameter("stability", stability)
        
    if collision_body:
        # Enable collision only when reasonably solid
        collision_body.process_mode = Node.PROCESS_MODE_INHERIT if stability > 0.4 else Node.PROCESS_MODE_DISABLED
        
    if omni_light:
        omni_light.light_energy = stability * 1.5
        if stability < 0.5:
            omni_light.light_color = Color(1.0, 0.2, 0.2)
        else:
            omni_light.light_color = Color(0.1, 0.85, 1.0)

func _on_became_unobserved() -> void:
    super._on_became_unobserved()
    if AudioManager.instance:
        AudioManager.instance.play_glitch()

func _on_became_observed() -> void:
    super._on_became_observed()
    if is_observed_by_camera:
        # Camera is locking reality
        pass
