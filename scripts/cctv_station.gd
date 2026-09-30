class_name CCTVStation
extends Node3D

signal station_accessed(camera_node: SecurityCamera)

@export var target_camera_path: NodePath
@export var prompt_message: String = "Press [E] to Access CCTV Console"

var target_camera: SecurityCamera
var screen_label: Label3D
var station_light: OmniLight3D

func _ready() -> void:
    add_to_group("interactables")
    _setup_model()
    
    if target_camera_path:
        target_camera = get_node_or_null(target_camera_path)

func _setup_model() -> void:
    var base = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(1.2, 1.2, 0.7)
    base.mesh = b_mesh
    base.position = Vector3(0, 0.6, 0)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.12, 0.15)
    mat.metallic = 0.8
    mat.roughness = 0.25
    base.material_override = mat
    add_child(base)
    
    # 3 monitor screens
    for i in range(3):
        var mon = MeshInstance3D.new()
        var m_mesh = QuadMesh.new()
        m_mesh.size = Vector2(0.4, 0.35)
        mon.mesh = m_mesh
        mon.position = Vector3((i - 1) * 0.44, 1.45, 0.22)
        mon.rotation_degrees.x = -15.0
        if i == 0:
            mon.rotation_degrees.y = 15.0
        elif i == 2:
            mon.rotation_degrees.y = -15.0
            
        var m_mat = StandardMaterial3D.new()
        m_mat.albedo_color = Color(0.02, 0.08, 0.12)
        m_mat.emission_enabled = true
        m_mat.emission = Color(0.1, 0.8, 1.0)
        m_mat.emission_energy_multiplier = 0.9
        mon.material_override = m_mat
        add_child(mon)
        
    screen_label = Label3D.new()
    screen_label.position = Vector3(0, 1.45, 0.24)
    screen_label.rotation_degrees.x = -15.0
    screen_label.pixel_size = 0.003
    screen_label.text = "CCTV INTERFACE // CAM-01\nSTATUS: ONLINE\n[E] TAKE MANUAL CONTROL"
    screen_label.modulate = Color(0.2, 1.0, 0.8)
    screen_label.outline_size = 4
    add_child(screen_label)
    
    station_light = OmniLight3D.new()
    station_light.position = Vector3(0, 1.5, 0.6)
    station_light.light_color = Color(0.1, 0.85, 0.9)
    station_light.light_energy = 1.4
    station_light.omni_range = 3.5
    add_child(station_light)
    
    # Collision
    var col_body = StaticBody3D.new()
    col_body.collision_layer = 3
    var col = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(1.4, 1.8, 0.9)
    col.shape = box
    col.position = Vector3(0, 0.9, 0)
    col_body.add_child(col)
    add_child(col_body)

func get_interaction_prompt() -> String:
    return prompt_message

func interact() -> void:
    if target_camera:
        emit_signal("station_accessed", target_camera)
        if AudioManager.instance:
            AudioManager.instance.play_beep(1.2)
