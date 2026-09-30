class_name SecurityCamera
extends Node3D

signal locked_target_changed(has_target: bool, target_name: String)

@export var camera_id: String = "CAM-01"
@export var min_yaw: float = -80.0
@export var max_yaw: float = 80.0
@export var min_pitch: float = -45.0
@export var max_pitch: float = 20.0
@export var pan_speed: float = 45.0

var base_mount: MeshInstance3D
var head_pivot: Node3D
var pitch_pivot: Node3D
var camera_node: Camera3D
var spot_light: SpotLight3D
var cone_mesh: MeshInstance3D
var status_led: OmniLight3D

var current_yaw: float = 25.0
var current_pitch: float = -15.0

var is_active: bool = true
var is_controlled: bool = false
var locked_target: String = ""
var target_lock_timer: float = 0.0

func _ready() -> void:
    _setup_camera_rig()
    add_to_group("security_cameras")
    if ObservationManager.instance:
        ObservationManager.instance.register_security_camera(self)
    _apply_rotation()

func _setup_camera_rig() -> void:
    # Wall/Pole base
    base_mount = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.25
    cyl.bottom_radius = 0.3
    cyl.height = 0.4
    base_mount.mesh = cyl
    var metal_mat = StandardMaterial3D.new()
    metal_mat.albedo_color = Color(0.15, 0.18, 0.22)
    metal_mat.metallic = 0.8
    metal_mat.roughness = 0.3
    base_mount.material_override = metal_mat
    add_child(base_mount)
    
    # Head yaw pivot
    head_pivot = Node3D.new()
    head_pivot.position = Vector3(0, 0.2, 0)
    add_child(head_pivot)
    
    # Head pitch pivot
    pitch_pivot = Node3D.new()
    head_pivot.add_child(pitch_pivot)
    
    # Camera casing
    var casing = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(0.5, 0.4, 0.9)
    casing.mesh = box
    casing.position = Vector3(0, 0, -0.2)
    casing.material_override = metal_mat
    pitch_pivot.add_child(casing)
    
    # Lens
    var lens = MeshInstance3D.new()
    var lens_mesh = CylinderMesh.new()
    lens_mesh.top_radius = 0.16
    lens_mesh.bottom_radius = 0.18
    lens_mesh.height = 0.2
    lens.mesh = lens_mesh
    lens.rotation_degrees.x = 90
    lens.position = Vector3(0, 0, -0.7)
    var lens_mat = StandardMaterial3D.new()
    lens_mat.albedo_color = Color(0.05, 0.05, 0.05)
    lens_mat.metallic = 0.9
    lens_mat.roughness = 0.1
    lens.material_override = lens_mat
    pitch_pivot.add_child(lens)
    
    # Camera3D node
    camera_node = Camera3D.new()
    camera_node.fov = 65.0
    camera_node.position = Vector3(0, 0, -0.75)
    camera_node.current = false
    pitch_pivot.add_child(camera_node)
    
    # Status LED
    status_led = OmniLight3D.new()
    status_led.position = Vector3(0.18, 0.15, -0.5)
    status_led.light_color = Color(0.1, 0.8, 1.0)
    status_led.light_energy = 1.0
    status_led.omni_range = 1.5
    pitch_pivot.add_child(status_led)
    
    # Surveillance Spotlight Cone
    spot_light = SpotLight3D.new()
    spot_light.position = Vector3(0, 0, -0.75)
    spot_light.light_color = Color(0.2, 0.8, 1.0)
    spot_light.light_energy = 2.8
    spot_light.spot_range = 28.0
    spot_light.spot_angle = 32.0
    spot_light.spot_attenuation = 1.2
    pitch_pivot.add_child(spot_light)
    
    # Semi-transparent surveillance beam volume
    cone_mesh = MeshInstance3D.new()
    var c_mesh = CylinderMesh.new()
    c_mesh.top_radius = 0.2
    c_mesh.bottom_radius = 6.0
    c_mesh.height = 20.0
    cone_mesh.mesh = c_mesh
    cone_mesh.position = Vector3(0, 0, -10.0)
    cone_mesh.rotation_degrees.x = -90
    
    var cone_mat = StandardMaterial3D.new()
    cone_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    cone_mat.albedo_color = Color(0.1, 0.7, 1.0, 0.06)
    cone_mat.emission_enabled = true
    cone_mat.emission = Color(0.1, 0.7, 1.0)
    cone_mat.emission_energy_multiplier = 0.4
    cone_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    cone_mesh.material_override = cone_mat
    pitch_pivot.add_child(cone_mesh)

func _process(delta: float) -> void:
    if target_lock_timer > 0.0:
        target_lock_timer -= delta
        if target_lock_timer <= 0.0:
            _clear_target_lock()

func get_aim_direction() -> Vector3:
    if pitch_pivot:
        return -pitch_pivot.global_transform.basis.z
    return -global_transform.basis.z

func is_camera_active() -> bool:
    return is_active

func set_target_in_view(target_name: String) -> void:
    target_lock_timer = 0.25
    if locked_target != target_name:
        locked_target = target_name
        if status_led:
            status_led.light_color = Color(0.1, 1.0, 0.4) # Green locked
        if spot_light:
            spot_light.light_color = Color(0.2, 1.0, 0.5)
        emit_signal("locked_target_changed", true, target_name)

func _clear_target_lock() -> void:
    locked_target = ""
    if status_led:
        status_led.light_color = Color(0.1, 0.8, 1.0)
    if spot_light:
        spot_light.light_color = Color(0.2, 0.8, 1.0)
    emit_signal("locked_target_changed", false, "")

func pan_tilt(yaw_input: float, pitch_input: float, delta: float) -> void:
    var moved = (yaw_input != 0.0 or pitch_input != 0.0)
    if moved and AudioManager.instance:
        AudioManager.instance.start_servo()
    else:
        if AudioManager.instance:
            AudioManager.instance.stop_servo()
            
    current_yaw = clamp(current_yaw + yaw_input * pan_speed * delta, min_yaw, max_yaw)
    current_pitch = clamp(current_pitch + pitch_input * pan_speed * delta, min_pitch, max_pitch)
    _apply_rotation()

func _apply_rotation() -> void:
    if head_pivot:
        head_pivot.rotation_degrees.y = current_yaw
    if pitch_pivot:
        pitch_pivot.rotation_degrees.x = current_pitch

func set_camera_view_active(active: bool) -> void:
    is_controlled = active
    if camera_node:
        if active:
            camera_node.make_current()
        else:
            camera_node.clear_current(false)
    if not active and AudioManager.instance:
        AudioManager.instance.stop_servo()
