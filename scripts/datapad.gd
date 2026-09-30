class_name Datapad
extends Node3D

signal datapad_read(log_title: String, log_author: String, log_body: String)

@export var datapad_id: String = "LOG_01"
@export var log_title: String = "INCIDENT REPORT: BLINK ANOMALY"
@export var log_author: String = "DR. A. VANCE // ARCHIVE ENGR"
@export_multiline var log_body: String = "It started with the streetlamps on 4th Ave.\n\nWhen I looked away, the fixtures changed from halogen to LED arrays. I timed it: exactly 220 milliseconds—the length of a human blink.\n\nThe system isn't simulating a physical world that runs in the background. It only renders when a sensory feed confirms an observer is active. Everything else dissolves into latent RAM.\n\nGod help us if all the cameras go down at once."

var pad_mesh: MeshInstance3D
var pad_light: OmniLight3D
var is_read: bool = false

func _ready() -> void:
    add_to_group("interactables")
    _build_datapad()

func _build_datapad() -> void:
    pad_mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(0.35, 0.04, 0.5)
    pad_mesh.mesh = box
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.12, 0.16)
    mat.metallic = 0.9
    mat.roughness = 0.2
    pad_mesh.material_override = mat
    add_child(pad_mesh)
    
    # Glowing screen
    var screen = MeshInstance3D.new()
    var s_mesh = QuadMesh.new()
    s_mesh.size = Vector2(0.3, 0.42)
    screen.mesh = s_mesh
    screen.position = Vector3(0, 0.025, 0)
    screen.rotation_degrees.x = -90.0
    
    var s_mat = StandardMaterial3D.new()
    s_mat.albedo_color = Color(0.05, 0.15, 0.2)
    s_mat.emission_enabled = true
    s_mat.emission = Color(0.1, 0.85, 1.0)
    s_mat.emission_energy_multiplier = 1.2
    screen.material_override = s_mat
    add_child(screen)
    
    # Beacon light
    pad_light = OmniLight3D.new()
    pad_light.position = Vector3(0, 0.25, 0)
    pad_light.light_color = Color(0.1, 0.85, 1.0)
    pad_light.light_energy = 0.8
    pad_light.omni_range = 2.0
    add_child(pad_light)
    
    # Collision for raycast
    var body = StaticBody3D.new()
    body.collision_layer = 3
    var col = CollisionShape3D.new()
    var c_box = BoxShape3D.new()
    c_box.size = Vector3(0.5, 0.3, 0.6)
    col.shape = c_box
    body.add_child(col)
    add_child(body)

func get_interaction_prompt() -> String:
    return "Press [E] to Decrypt Datapad [%s]" % datapad_id

func interact() -> void:
    is_read = true
    if AudioManager.instance:
        AudioManager.instance.play_datapad()
    if pad_light:
        pad_light.light_color = Color(0.2, 1.0, 0.6)
    emit_signal("datapad_read", log_title, log_author, log_body)
