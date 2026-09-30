class_name Terminal
extends Node3D

signal interacted(terminal_id: String)

@export var terminal_id: String = "TERM_OVERRIDE"
@export var prompt_message: String = "Press [E] to Access Console"
@export var header_text: String = "WATCHER SUB-TERMINAL 04"
@export var log_message: String = "SYSTEM STANDBY"
@export var is_usable: bool = true
@export var trigger_once: bool = false

var has_triggered: bool = false
var console_light: OmniLight3D
var screen_mesh: MeshInstance3D
var screen_label: Label3D

func _ready() -> void:
    add_to_group("interactables")
    _setup_terminal_model()

func _setup_terminal_model() -> void:
    # Pedestal body
    var body = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(0.9, 1.1, 0.6)
    body.mesh = b_mesh
    body.position = Vector3(0, 0.55, 0)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.12, 0.13, 0.16)
    mat.metallic = 0.85
    mat.roughness = 0.3
    body.material_override = mat
    add_child(body)
    
    # Angled top screen casing
    var top = MeshInstance3D.new()
    var top_mesh = BoxMesh.new()
    top_mesh.size = Vector3(0.85, 0.6, 0.45)
    top.mesh = top_mesh
    top.position = Vector3(0, 1.25, -0.05)
    top.rotation_degrees.x = -20.0
    top.material_override = mat
    add_child(top)
    
    # Screen face
    screen_mesh = MeshInstance3D.new()
    var s_mesh = QuadMesh.new()
    s_mesh.size = Vector2(0.75, 0.45)
    screen_mesh.mesh = s_mesh
    screen_mesh.position = Vector3(0, 1.28, 0.17)
    screen_mesh.rotation_degrees.x = -20.0
    var s_mat = StandardMaterial3D.new()
    s_mat.albedo_color = Color(0.02, 0.12, 0.15)
    s_mat.emission_enabled = true
    s_mat.emission = Color(0.1, 0.7, 0.9)
    s_mat.emission_energy_multiplier = 0.8
    screen_mesh.material_override = s_mat
    add_child(screen_mesh)
    
    # 3D Screen text
    screen_label = Label3D.new()
    screen_label.position = Vector3(0, 1.28, 0.19)
    screen_label.rotation_degrees.x = -20.0
    screen_label.pixel_size = 0.003
    screen_label.text = "%s\n---\n%s" % [header_text, log_message]
    screen_label.modulate = Color(0.2, 0.95, 1.0)
    screen_label.outline_size = 4
    screen_label.outline_modulate = Color(0, 0.1, 0.2)
    add_child(screen_label)
    
    # Glow light
    console_light = OmniLight3D.new()
    console_light.position = Vector3(0, 1.3, 0.5)
    console_light.light_color = Color(0.2, 0.85, 1.0)
    console_light.light_energy = 1.0
    console_light.omni_range = 3.0
    add_child(console_light)
    
    # Static collision for interaction raycast
    var col_body = StaticBody3D.new()
    col_body.collision_layer = 3 # Layer 1 & 2
    var col = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(1.0, 1.6, 0.8)
    col.shape = box
    col.position = Vector3(0, 0.8, 0)
    col_body.add_child(col)
    add_child(col_body)

func get_interaction_prompt() -> String:
    if not is_usable or (trigger_once and has_triggered):
        return ""
    return prompt_message

func interact() -> void:
    if not is_usable or (trigger_once and has_triggered):
        return
        
    has_triggered = true
    if AudioManager.instance:
        AudioManager.instance.play_terminal()
        
    emit_signal("interacted", terminal_id)

func set_log(new_text: String, alert_color: bool = false) -> void:
    log_message = new_text
    if screen_label:
        screen_label.text = "%s\n---\n%s" % [header_text, log_message]
        if alert_color:
            screen_label.modulate = Color(1.0, 0.4, 0.2)
            if console_light:
                console_light.light_color = Color(1.0, 0.4, 0.2)
        else:
            screen_label.modulate = Color(0.2, 0.95, 1.0)
            if console_light:
                console_light.light_color = Color(0.2, 0.85, 1.0)
