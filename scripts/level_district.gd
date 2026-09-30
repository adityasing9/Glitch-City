class_name LevelDistrict
extends Node3D

var bridge: ObservableBridge
var camera_station: CCTVStation
var security_camera: SecurityCamera
var sign_billboard: ObservableSign
var security_door: ObservableDoor
var override_terminal: Terminal
var final_terminal: Terminal

var dark_metal_mat: StandardMaterial3D
var dark_concrete_mat: StandardMaterial3D
var neon_cyan_mat: StandardMaterial3D
var neon_magenta_mat: StandardMaterial3D
var neon_amber_mat: StandardMaterial3D

func _ready() -> void:
    _init_materials()
    _build_environment()
    _spawn_interactive_elements()

func _init_materials() -> void:
    dark_metal_mat = StandardMaterial3D.new()
    dark_metal_mat.albedo_color = Color(0.08, 0.09, 0.12)
    dark_metal_mat.metallic = 0.8
    dark_metal_mat.roughness = 0.25

    dark_concrete_mat = StandardMaterial3D.new()
    dark_concrete_mat.albedo_color = Color(0.12, 0.13, 0.15)
    dark_concrete_mat.roughness = 0.85
    dark_concrete_mat.metallic = 0.1

    neon_cyan_mat = StandardMaterial3D.new()
    neon_cyan_mat.albedo_color = Color(0.1, 0.85, 1.0)
    neon_cyan_mat.emission_enabled = true
    neon_cyan_mat.emission = Color(0.1, 0.85, 1.0)
    neon_cyan_mat.emission_energy_multiplier = 3.5

    neon_magenta_mat = StandardMaterial3D.new()
    neon_magenta_mat.albedo_color = Color(1.0, 0.1, 0.6)
    neon_magenta_mat.emission_enabled = true
    neon_magenta_mat.emission = Color(1.0, 0.1, 0.6)
    neon_magenta_mat.emission_energy_multiplier = 3.5

    neon_amber_mat = StandardMaterial3D.new()
    neon_amber_mat.albedo_color = Color(1.0, 0.6, 0.1)
    neon_amber_mat.emission_enabled = true
    neon_amber_mat.emission = Color(1.0, 0.6, 0.1)
    neon_amber_mat.emission_energy_multiplier = 3.0

func _build_environment() -> void:
    # 1. Starting Street / Sector 07 Plaza (South of Chasm: Z = 0 to 24)
    _create_platform(Vector3(0, -0.5, 12), Vector3(22.0, 1.0, 24.0), dark_concrete_mat)
    
    # Street road markings & curb
    _create_box(Vector3(-10.5, 0.3, 12), Vector3(1.0, 0.6, 24.0), dark_metal_mat)
    _create_box(Vector3(10.5, 0.3, 12), Vector3(1.0, 0.6, 24.0), dark_metal_mat)
    
    # Neon street trim lines
    _create_box(Vector3(-9.8, 0.05, 12), Vector3(0.15, 0.1, 24.0), neon_cyan_mat, false)
    _create_box(Vector3(9.8, 0.05, 12), Vector3(0.15, 0.1, 24.0), neon_magenta_mat, false)

    # South Wall (blocking map boundary)
    _create_box(Vector3(0, 4.0, 24.0), Vector3(22.0, 8.0, 1.0), dark_concrete_mat)
    
    # West & East Buildings (Silhouettes and facades)
    _create_building(Vector3(-14, 12, 12), Vector3(8, 24, 26), Color(0.1, 0.85, 1.0))
    _create_building(Vector3(14, 12, 12), Vector3(8, 24, 26), Color(1.0, 0.1, 0.6))
    
    # 2. Glitch Chasm (Z = -0.5 to -11.5)
    _create_chasm_details()
    
    # 3. North Plaza / Across Chasm (Z = -12 to -36)
    _create_platform(Vector3(0, -0.5, -24), Vector3(22.0, 1.0, 24.0), dark_concrete_mat)
    _create_box(Vector3(-10.5, 0.3, -24), Vector3(1.0, 0.6, 24.0), dark_metal_mat)
    _create_box(Vector3(10.5, 0.3, -24), Vector3(1.0, 0.6, 24.0), dark_metal_mat)
    
    _create_building(Vector3(-14, 12, -24), Vector3(8, 24, 26), Color(1.0, 0.6, 0.1))
    _create_building(Vector3(14, 12, -24), Vector3(8, 24, 26), Color(0.1, 0.85, 1.0))

    # Barrier dividing North Plaza and Inner WATCHER Core
    _create_box(Vector3(-6.5, 4.0, -32), Vector3(9.0, 8.0, 1.2), dark_concrete_mat)
    _create_box(Vector3(6.5, 4.0, -32), Vector3(9.0, 8.0, 1.2), dark_concrete_mat)
    _create_box(Vector3(0, 7.0, -32), Vector3(4.0, 2.0, 1.2), dark_metal_mat) # Door lintel

    # 4. Inner WATCHER Server Room (Z = -32 to -48)
    _create_platform(Vector3(0, -0.5, -40), Vector3(14.0, 1.0, 16.0), dark_metal_mat)
    _create_box(Vector3(-7.0, 4.0, -40), Vector3(1.0, 8.0, 16.0), dark_concrete_mat) # West wall
    _create_box(Vector3(7.0, 4.0, -40), Vector3(1.0, 8.0, 16.0), dark_concrete_mat) # East wall
    _create_box(Vector3(0, 4.0, -48), Vector3(14.0, 8.0, 1.0), dark_concrete_mat) # North back wall
    _create_box(Vector3(0, 8.0, -40), Vector3(14.0, 0.5, 16.0), dark_metal_mat) # Ceiling

    # Server racks in server room
    for i in range(4):
        _create_server_rack(Vector3(-4.8, 1.8, -35.0 - (i * 2.8)))
        _create_server_rack(Vector3(4.8, 1.8, -35.0 - (i * 2.8)))

    # Atmospheric Lighting
    _create_street_lamp(Vector3(-8.5, 0, 18), Color(0.1, 0.8, 1.0))
    _create_street_lamp(Vector3(8.5, 0, 18), Color(1.0, 0.2, 0.6))
    _create_street_lamp(Vector3(-8.5, 0, 5), Color(0.1, 0.8, 1.0))
    _create_street_lamp(Vector3(8.5, 0, 5), Color(1.0, 0.2, 0.6))
    
    _create_street_lamp(Vector3(-8.5, 0, -16), Color(1.0, 0.6, 0.1))
    _create_street_lamp(Vector3(8.5, 0, -16), Color(0.1, 0.8, 1.0))
    _create_street_lamp(Vector3(0, 0, -28), Color(0.2, 0.9, 0.7))

    # Server room core light
    var core_light = OmniLight3D.new()
    core_light.position = Vector3(0, 4.5, -42)
    core_light.light_color = Color(0.1, 0.9, 1.0)
    core_light.light_energy = 3.0
    core_light.omni_range = 14.0
    add_child(core_light)

func _create_chasm_details() -> void:
    # Danger warning curb on South edge (Z = 0)
    _create_box(Vector3(-5.5, 0.2, 0.2), Vector3(11.0, 0.4, 0.4), neon_amber_mat, true)
    _create_box(Vector3(5.5, 0.2, 0.2), Vector3(11.0, 0.4, 0.4), neon_amber_mat, true)
    
    # Danger warning curb on North edge (Z = -12)
    _create_box(Vector3(-5.5, 0.2, -12.2), Vector3(11.0, 0.4, 0.4), neon_amber_mat, true)
    _create_box(Vector3(5.5, 0.2, -12.2), Vector3(11.0, 0.4, 0.4), neon_amber_mat, true)

    # Chasm glowing floor / abyss indicator
    var abyss_floor = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(24.0, 14.0)
    abyss_floor.mesh = plane
    abyss_floor.position = Vector3(0, -15.0, -6.0)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.01, 0.02, 0.05)
    mat.emission_enabled = true
    mat.emission = Color(0.3, 0.0, 0.5)
    mat.emission_energy_multiplier = 0.4
    abyss_floor.material_override = mat
    add_child(abyss_floor)

func _create_building(pos: Vector3, size: Vector3, neon_color: Color) -> void:
    _create_box(pos, size, dark_concrete_mat, true)
    
    # Neon window strips
    for y in range(4, int(size.y) - 2, 4):
        var strip = MeshInstance3D.new()
        var s_mesh = BoxMesh.new()
        s_mesh.size = Vector3(0.2, 0.4, size.z * 0.8)
        strip.mesh = s_mesh
        strip.position = Vector3(pos.x + (size.x * 0.51 * sign(pos.x * -1.0)), y, pos.z)
        var s_mat = StandardMaterial3D.new()
        s_mat.albedo_color = neon_color
        s_mat.emission_enabled = true
        s_mat.emission = neon_color
        s_mat.emission_energy_multiplier = 2.0
        strip.material_override = s_mat
        add_child(strip)

func _create_server_rack(pos: Vector3) -> void:
    _create_box(pos, Vector3(1.2, 3.4, 1.8), dark_metal_mat, true)
    # Server blinker LED mesh
    var leds = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(0.05, 3.0, 1.4)
    leds.mesh = b_mesh
    leds.position = Vector3(pos.x + 0.61 * (1.0 if pos.x < 0 else -1.0), pos.y, pos.z)
    var l_mat = StandardMaterial3D.new()
    l_mat.albedo_color = Color(0.1, 0.9, 0.4)
    l_mat.emission_enabled = true
    l_mat.emission = Color(0.1, 0.9, 0.4)
    l_mat.emission_energy_multiplier = 1.5
    leds.material_override = l_mat
    add_child(leds)

func _create_street_lamp(pos: Vector3, light_col: Color) -> void:
    # Pole
    _create_box(pos + Vector3(0, 3.0, 0), Vector3(0.25, 6.0, 0.25), dark_metal_mat, true)
    # Overhang arm
    _create_box(pos + Vector3(0.8, 5.8, 0), Vector3(1.6, 0.2, 0.25), dark_metal_mat, false)
    # Lamp head
    var lamp_head = MeshInstance3D.new()
    var h_mesh = BoxMesh.new()
    h_mesh.size = Vector3(0.6, 0.15, 0.3)
    lamp_head.mesh = h_mesh
    lamp_head.position = pos + Vector3(1.4, 5.7, 0)
    var h_mat = StandardMaterial3D.new()
    h_mat.albedo_color = light_col
    h_mat.emission_enabled = true
    h_mat.emission = light_col
    h_mat.emission_energy_multiplier = 4.0
    lamp_head.material_override = h_mat
    add_child(lamp_head)
    
    var light = SpotLight3D.new()
    light.position = pos + Vector3(1.4, 5.6, 0)
    light.rotation_degrees.x = -90.0
    light.light_color = light_col
    light.light_energy = 3.5
    light.spot_range = 14.0
    light.spot_angle = 50.0
    add_child(light)

func _create_platform(pos: Vector3, size: Vector3, mat: Material) -> void:
    _create_box(pos, size, mat, true)

func _create_box(pos: Vector3, size: Vector3, mat: Material, has_collision: bool = true) -> MeshInstance3D:
    var inst = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = size
    inst.mesh = box
    inst.position = pos
    inst.material_override = mat
    add_child(inst)
    
    if has_collision:
        var body = StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        var col = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        col.shape = shape
        body.add_child(col)
        body.position = pos
        add_child(body)
        
    return inst

func _spawn_interactive_elements() -> void:
    # 1. Hologram Billboard in District Plaza (South side)
    sign_billboard = ObservableSign.new()
    sign_billboard.position = Vector3(0, 3.8, 22.8)
    sign_billboard.rotation_degrees.y = 180.0
    add_child(sign_billboard)
    if ObservationManager.instance:
        ObservationManager.instance.register_observable(sign_billboard)

    # 2. Observable Quantum Bridge spanning the Chasm (Center at Z = -6.0)
    bridge = ObservableBridge.new()
    bridge.length = 12.4
    bridge.width = 3.6
    bridge.position = Vector3(0, 0, -6.0)
    add_child(bridge)
    if ObservationManager.instance:
        ObservationManager.instance.register_observable(bridge)

    # 3. Security Camera CAM-01 (Mounted on pole overlooking Chasm and Bridge)
    security_camera = SecurityCamera.new()
    security_camera.camera_id = "CAM-01"
    security_camera.position = Vector3(5.5, 4.8, 1.8)
    security_camera.rotation_degrees.y = 15.0 # Pointed slightly toward bridge
    security_camera.current_yaw = 20.0
    security_camera.current_pitch = -18.0
    add_child(security_camera)

    # 4. CCTV Console Station (Right by the camera post)
    camera_station = CCTVStation.new()
    camera_station.position = Vector3(5.2, 0, 4.0)
    camera_station.rotation_degrees.y = 180.0
    camera_station.target_camera = security_camera
    add_child(camera_station)

    # 5. Across Bridge: Sub-Terminal 04 (Maintenance Override)
    override_terminal = Terminal.new()
    override_terminal.terminal_id = "TERM_MAINTENANCE"
    override_terminal.prompt_message = "Press [E] to Access Maintenance Terminal"
    override_terminal.header_text = "MAINTENANCE TERMINAL // GATE 07"
    override_terminal.log_message = "STATUS: GATE LOCKED\nEXECUTE OVERRIDE TO PROCEED"
    override_terminal.position = Vector3(-4.5, 0, -22.0)
    override_terminal.rotation_degrees.y = 90.0
    add_child(override_terminal)

    # 6. Observable Security Gate 07 (at Z = -32.0)
    security_door = ObservableDoor.new()
    security_door.position = Vector3(0, 0, -32.0)
    add_child(security_door)
    if ObservationManager.instance:
        ObservationManager.instance.register_observable(security_door)

    # 7. Final Central WATCHER Terminal (Inside Core Room at Z = -45.0)
    final_terminal = Terminal.new()
    final_terminal.terminal_id = "TERM_WATCHER_CORE"
    final_terminal.prompt_message = "Press [E] to Interface with WATCHER Core"
    final_terminal.header_text = "CENTRAL SURVEILLANCE NEXUS: WATCHER"
    final_terminal.log_message = "CORE READY FOR CONVERGENCE"
    final_terminal.position = Vector3(0, 0, -44.5)
    add_child(final_terminal)
