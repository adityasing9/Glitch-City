class_name ObservableSign
extends ObservableObject

@export var messages: Array[String] = [
    "DISTRICT 07 // SURVEILLANCE LEVEL 4\nALL ANOMALIES SUBJECT TO PURGE",
    "WARNING: QUANTUM DRIFT DETECTED\nDO NOT LOOK AWAY",
    "WATCHER SUBROUTINE ACTIVE\nOBSERVATION DEFINES EXISTENCE",
    "THE SYSTEM IS NOT BROKEN\nWATCHER DECIDES WHAT EXISTS"
]

var label: Label3D
var frame_mesh: MeshInstance3D
var sign_light: OmniLight3D
var message_index: int = 0
var change_pending: bool = false

func _init_observable() -> void:
    object_name = "Surveillance Hologram Sign"
    _setup_sign()

func _setup_sign() -> void:
    # Frame backing
    frame_mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(5.0, 1.8, 0.2)
    frame_mesh.mesh = box
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.05, 0.07, 0.1)
    mat.metallic = 0.9
    mat.roughness = 0.2
    frame_mesh.material_override = mat
    add_child(frame_mesh)
    
    # Border neon trim
    var trim = MeshInstance3D.new()
    var trim_mesh = BoxMesh.new()
    trim_mesh.size = Vector3(5.1, 1.9, 0.05)
    trim.mesh = trim_mesh
    trim.position = Vector3(0, 0, 0.08)
    var trim_mat = StandardMaterial3D.new()
    trim_mat.albedo_color = Color(0.1, 0.9, 1.0)
    trim_mat.emission_enabled = true
    trim_mat.emission = Color(0.1, 0.9, 1.0)
    trim_mat.emission_energy_multiplier = 2.0
    trim.material_override = trim_mat
    add_child(trim)
    
    # Label3D
    label = Label3D.new()
    label.position = Vector3(0, 0, 0.12)
    label.pixel_size = 0.007
    label.text = messages[0]
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.modulate = Color(0.2, 0.95, 1.0)
    label.outline_modulate = Color(0.0, 0.1, 0.3)
    label.outline_size = 8
    add_child(label)
    
    sign_light = OmniLight3D.new()
    sign_light.position = Vector3(0, 0, 0.5)
    sign_light.light_color = Color(0.2, 0.9, 1.0)
    sign_light.light_energy = 1.0
    sign_light.omni_range = 6.0
    add_child(sign_light)

func trigger_story_advance() -> void:
    change_pending = true

func _on_became_unobserved() -> void:
    super._on_became_unobserved()
    # Reality changes when player is NOT looking!
    if change_pending or randf() < 0.6:
        change_pending = false
        message_index = (message_index + 1) % messages.size()
        _update_visuals()

func _update_visuals() -> void:
    if not label:
        return
    label.text = messages[message_index]
    
    match message_index:
        0:
            label.modulate = Color(0.2, 0.95, 1.0)
            sign_light.light_color = Color(0.2, 0.95, 1.0)
        1:
            label.modulate = Color(1.0, 0.7, 0.1)
            sign_light.light_color = Color(1.0, 0.7, 0.1)
        2:
            label.modulate = Color(1.0, 0.2, 0.4)
            sign_light.light_color = Color(1.0, 0.2, 0.4)
        3:
            label.modulate = Color(0.9, 0.1, 0.9)
            sign_light.light_color = Color(0.9, 0.1, 0.9)
