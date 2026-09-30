class_name ObservationManager
extends Node

static var instance: ObservationManager

var player_camera: Camera3D
var security_cameras: Array[Node3D] = []
var observable_objects: Array[ObservableObject] = []

var reality_coherence: float = 1.0
var target_coherence: float = 1.0
var glitch_burst: float = 0.0

signal reality_coherence_updated(coherence: float)
signal glitch_triggered(intensity: float)

func _ready() -> void:
    instance = self

func register_player_camera(cam: Camera3D) -> void:
    player_camera = cam

func register_security_camera(cam: Node3D) -> void:
    if not security_cameras.has(cam):
        security_cameras.append(cam)

func unregister_security_camera(cam: Node3D) -> void:
    security_cameras.erase(cam)

func register_observable(obj: ObservableObject) -> void:
    if not observable_objects.has(obj):
        observable_objects.append(obj)

func unregister_observable(obj: ObservableObject) -> void:
    observable_objects.erase(obj)

func _physics_process(delta: float) -> void:
    var space_state = null
    if player_camera and player_camera.get_world_3d():
        space_state = player_camera.get_world_3d().direct_space_state
    
    var unobserved_critical_count = 0
    
    for obj in observable_objects:
        if not is_instance_valid(obj) or not obj.is_inside_tree():
            continue
            
        var pts = obj.get_observation_points()
        var observed_by_player = false
        var observed_by_camera = false
        
        # 1. Check Player Observation
        if player_camera and is_instance_valid(player_camera):
            observed_by_player = _check_observer_sees_points(
                player_camera.global_position,
                -player_camera.global_transform.basis.z,
                player_camera.fov,
                40.0,
                pts,
                space_state,
                player_camera
            )
        
        # 2. Check Security Cameras
        for sec_cam in security_cameras:
            if not is_instance_valid(sec_cam) or not sec_cam.is_inside_tree():
                continue
            if sec_cam.has_method("is_camera_active") and not sec_cam.is_camera_active():
                continue
                
            var cam_pos = sec_cam.global_position
            if sec_cam.has_node("Head/CameraMount"):
                cam_pos = sec_cam.get_node("Head/CameraMount").global_position
                
            var cam_forward = -sec_cam.global_transform.basis.z
            if sec_cam.has_method("get_aim_direction"):
                cam_forward = sec_cam.get_aim_direction()
            
            var cam_fov = 65.0
            var cam_range = 35.0
            
            if _check_observer_sees_points(cam_pos, cam_forward, cam_fov, cam_range, pts, space_state, null):
                observed_by_camera = true
                if sec_cam.has_method("set_target_in_view"):
                    sec_cam.set_target_in_view(obj.object_name)
                break
        
        var prev_observed = obj.is_observed
        obj.update_observation_state(observed_by_player, observed_by_camera, delta)
        
        # Trigger glitch if reality changes state
        if prev_observed != obj.is_observed:
            trigger_glitch_effect(0.5)
            
        if not obj.is_observed:
            unobserved_critical_count += 1

    # Coherence logic
    if unobserved_critical_count > 0:
        target_coherence = clamp(1.0 - (unobserved_critical_count * 0.18), 0.35, 1.0)
    else:
        target_coherence = 1.0
        
    reality_coherence = lerp(reality_coherence, target_coherence, delta * 3.0)
    emit_signal("reality_coherence_updated", reality_coherence)
    
    if glitch_burst > 0.0:
        glitch_burst = max(0.0, glitch_burst - delta * 2.5)

func _check_observer_sees_points(origin: Vector3, forward: Vector3, fov_deg: float, max_dist: float, pts: Array[Vector3], space_state: PhysicsDirectSpaceState3D, cam: Camera3D) -> bool:
    var cos_half_fov = cos(deg_to_rad(fov_deg * 0.55))
    
    for pt in pts:
        var to_pt = pt - origin
        var dist = to_pt.length()
        if dist > max_dist or dist < 0.2:
            continue
            
        var dir = to_pt / dist
        if forward.dot(dir) < cos_half_fov:
            continue
            
        if cam and not cam.is_position_in_frustum(pt):
            continue
            
        # Raycast occlusion check
        if space_state:
            var query = PhysicsRayQueryParameters3D.create(origin + dir * 0.3, pt - dir * 0.2)
            query.collision_mask = 1 # Solid world geometry
            var result = space_state.intersect_ray(query)
            if result.is_empty():
                return true # Line of sight is clear!
        else:
            return true
            
    return false

func trigger_glitch_effect(intensity: float) -> void:
    glitch_burst = max(glitch_burst, intensity)
    emit_signal("glitch_triggered", glitch_burst)
    if AudioManager.instance:
        AudioManager.instance.play_glitch()
