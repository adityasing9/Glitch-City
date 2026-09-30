class_name Player
extends CharacterBody3D

signal interaction_prompt_changed(prompt_text: String)
signal player_fell_in_abyss

@export var walk_speed: float = 4.2
@export var sprint_speed: float = 6.8
@export var mouse_sensitivity: float = 0.0022
@export var head_bob_frequency: float = 2.4
@export var head_bob_amplitude: float = 0.04

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 14.0)

var head: Node3D
var camera: Camera3D
var interact_ray: RayCast3D

var is_locked: bool = false
var current_interactable: Node = null
var initial_spawn_point: Vector3

var bob_timer: float = 0.0
var step_timer: float = 0.0
var original_camera_y: float = 1.6

func _ready() -> void:
    _setup_components()
    initial_spawn_point = global_position
    
    if ObservationManager.instance:
        ObservationManager.instance.register_player_camera(camera)
        
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _setup_components() -> void:
    # Collision Capsule
    var col = CollisionShape3D.new()
    var capsule = CapsuleShape3D.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    col.shape = capsule
    col.position = Vector3(0, 0.9, 0)
    add_child(col)
    
    # Head & Camera
    head = Node3D.new()
    head.position = Vector3(0, 1.6, 0)
    add_child(head)
    
    camera = Camera3D.new()
    camera.fov = 75.0
    camera.near = 0.05
    camera.far = 150.0
    camera.current = true
    head.add_child(camera)
    original_camera_y = camera.position.y
    
    # Interaction RayCast
    interact_ray = RayCast3D.new()
    interact_ray.target_position = Vector3(0, 0, -3.2)
    interact_ray.collision_mask = 1 | 2 # world & interactables
    interact_ray.collide_with_areas = true
    interact_ray.collide_with_bodies = true
    camera.add_child(interact_ray)

func _unhandled_input(event: InputEvent) -> void:
    if is_locked:
        return
        
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        head.rotate_x(-event.relative.y * mouse_sensitivity)
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-88), deg_to_rad(88))

func _physics_process(delta: float) -> void:
    if is_locked:
        return
        
    _handle_movement(delta)
    _handle_interaction()
    _check_abyss()

func _handle_movement(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0

    var is_sprinting = Input.is_action_pressed("sprint")
    var current_speed = sprint_speed if is_sprinting else walk_speed

    var input_dir = Vector2.ZERO
    if Input.is_action_pressed("move_forward"):
        input_dir.y -= 1.0
    if Input.is_action_pressed("move_backward"):
        input_dir.y += 1.0
    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1.0
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1.0
    input_dir = input_dir.normalized()

    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
        
        # Head Bob & Footstep
        if is_on_floor():
            bob_timer += delta * head_bob_frequency * (1.4 if is_sprinting else 1.0)
            camera.position.y = original_camera_y + sin(bob_timer * TAU) * head_bob_amplitude
            
            step_timer += delta * (current_speed / walk_speed)
            if step_timer > 0.45:
                step_timer = 0.0
                if AudioManager.instance:
                    AudioManager.instance.play_footstep()
    else:
        velocity.x = move_toward(velocity.x, 0, current_speed * delta * 8.0)
        velocity.z = move_toward(velocity.z, 0, current_speed * delta * 8.0)
        camera.position.y = lerp(camera.position.y, original_camera_y, delta * 8.0)
        bob_timer = 0.0
        step_timer = 0.0

    move_and_slide()

func _handle_interaction() -> void:
    var hit_obj: Node = null
    var prompt_text = ""
    
    if interact_ray and interact_ray.is_colliding():
        var collider = interact_ray.get_collider()
        var candidate = collider
        while candidate and candidate != get_tree().root:
            if candidate.has_method("get_interaction_prompt"):
                hit_obj = candidate
                prompt_text = candidate.get_interaction_prompt()
                break
            candidate = candidate.get_parent()
            
    if current_interactable != hit_obj:
        current_interactable = hit_obj
        emit_signal("interaction_prompt_changed", prompt_text)
        
    if current_interactable and Input.is_action_just_pressed("interact"):
        if current_interactable.has_method("interact"):
            current_interactable.interact()
            # Refresh prompt
            emit_signal("interaction_prompt_changed", current_interactable.get_interaction_prompt())

func _check_abyss() -> void:
    if global_position.y < -12.0:
        # Fell off the unobserved bridge into the glitch abyss!
        emit_signal("player_fell_in_abyss")
        respawn()

func respawn() -> void:
    global_position = initial_spawn_point
    velocity = Vector3.ZERO
    if ObservationManager.instance:
        ObservationManager.instance.trigger_glitch_effect(1.0)

func lock_player(locked: bool) -> void:
    is_locked = locked
    velocity = Vector3.ZERO
    if locked:
        emit_signal("interaction_prompt_changed", "")
