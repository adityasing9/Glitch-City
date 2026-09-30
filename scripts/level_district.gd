class_name LevelDistrict
extends Node3D

var bridge: ObservableBridge
var camera_station: CCTVStation
var security_camera: SecurityCamera
var security_camera_2: SecurityCamera
var quantum_lift: QuantumPlatform
var sign_billboard: ObservableSign
var security_door: ObservableDoor
var override_terminal: Terminal
var final_terminal: Terminal

var datapads: Array[Datapad] = []

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
    
    # Elevated Catwalk on West Building (Z = 10, Y = 6.0) reached by Quantum Lift
    _create_box(Vector3(-7.5, 5.8, 10.0), Vector3(4.0, 0.4, 6.0), dark_metal_mat, true)
    _create_box(Vector3(-9.4, 6.6, 10.0), Vector3(0.2, 1.2, 6.0), neon_cyan_mat, true)
    
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
    _create_box(Vector3(0, 7.0, -32), Vector3(4.0, 2.0, 1.2), dark_metal_mat)

    # 4. Inner WATCHER Server Room (Z = -32 to -48)
    _create_platform(Vector3(0, -0.5, -40), Vector3(14.0, 1.0, 16.0), dark_metal_mat)
    _create_box(Vector3(-7.0, 4.0, -40), Vector3(1.0, 8.0, 16.0), dark_concrete_mat)
    _create_box(Vector3(7.0, 4.0, -40), Vector3(1.0, 8.0, 16.0), dark_concrete_mat)
    _create_box(Vector3(0, 4.0, -48), Vector3(14.0, 8.0, 1.0), dark_concrete_mat)
    _create_box(Vector3(0, 8.0, -40), Vector3(14.0, 0.5, 16.0), dark_metal_mat)

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

    # Steam Vents
    _create_steam_vent(Vector3(-3.5, 0.05, 14.0))
    _create_steam_vent(Vector3(4.0, 0.05, -18.0))

    # Server room core light
    var core_light = OmniLight3D.new()
    core_light.position = Vector3(0, 4.5, -42)
    core_light.light_color = Color(0.1, 0.9, 1.0)
    core_light.light_energy = 3.0
    core_light.omni_range = 14.0
    add_child(core_light)

func _create_chasm_details() -> void:
    # Danger warning curbs on South edge with 4.4m wide OPENING for bridge entrance at center
    _create_box(Vector3(-6.6, 0.2, 0.2), Vector3(8.8, 0.4, 0.4), neon_amber_mat, true)
    _create_box(Vector3(6.6, 0.2, 0.2), Vector3(8.8, 0.4, 0.4), neon_amber_mat, true)
    
    # Danger warning curbs on North edge with 4.4m wide OPENING for bridge exit
    _create_box(Vector3(-6.6, 0.2, -12.2), Vector3(8.8, 0.4, 0.4), neon_amber_mat, true)
    _create_box(Vector3(6.6, 0.2, -12.2), Vector3(8.8, 0.4, 0.4), neon_amber_mat, true)

    # South Bridge Entrance Guide Pylons (Glowing Cyan)
    _create_box(Vector3(-2.0, 0.8, 0.3), Vector3(0.3, 1.6, 0.3), neon_cyan_mat, true)
    _create_box(Vector3(2.0, 0.8, 0.3), Vector3(0.3, 1.6, 0.3), neon_cyan_mat, true)

    # North Bridge Exit Guide Pylons (Glowing Cyan)
    _create_box(Vector3(-2.0, 0.8, -12.3), Vector3(0.3, 1.6, 0.3), neon_cyan_mat, true)
    _create_box(Vector3(2.0, 0.8, -12.3), Vector3(0.3, 1.6, 0.3), neon_cyan_mat, true)

    # Floor runway light strips pointing directly onto bridge
    for z_off in [1.0, 2.5, 4.0]:
        _create_box(Vector3(0, 0.02, z_off), Vector3(0.3, 0.04, 0.8), neon_cyan_mat, false)
        _create_box(Vector3(-1.8, 0.02, z_off), Vector3(0.1, 0.04, 0.8), neon_amber_mat, false)
        _create_box(Vector3(1.8, 0.02, z_off), Vector3(0.1, 0.04, 0.8), neon_amber_mat, false)

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

func _create_steam_vent(pos: Vector3) -> void:
    # Grate mesh
    var grate = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.top_radius = 0.6
    cyl.bottom_radius = 0.6
    cyl.height = 0.1
    grate.mesh = cyl
    grate.position = pos
    grate.material_override = dark_metal_mat
    add_child(grate)
    
    # Steam vapor light
    var s_light = OmniLight3D.new()
    s_light.position = pos + Vector3(0, 0.8, 0)
    s_light.light_color = Color(0.2, 0.8, 1.0)
    s_light.light_energy = 0.6
    s_light.omni_range = 2.5
    add_child(s_light)

func _create_building(pos: Vector3, size: Vector3, neon_color: Color) -> void:
    _create_box(pos, size, dark_concrete_mat, true)
    
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
    _create_box(pos + Vector3(0, 3.0, 0), Vector3(0.25, 6.0, 0.25), dark_metal_mat, true)
    _create_box(pos + Vector3(0.8, 5.8, 0), Vector3(1.6, 0.2, 0.25), dark_metal_mat, false)
    
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

    # 3. Security Camera CAM-01 (Chasm Bridge surveillance)
    security_camera = SecurityCamera.new()
    security_camera.camera_id = "CAM-01"
    security_camera.position = Vector3(5.5, 4.8, 1.8)
    security_camera.rotation_degrees.y = 15.0
    security_camera.current_yaw = 20.0
    security_camera.current_pitch = -18.0
    add_child(security_camera)

    # 4. Security Camera CAM-02 (Rooftop / Alleyway surveillance)
    security_camera_2 = SecurityCamera.new()
    security_camera_2.camera_id = "CAM-02"
    security_camera_2.position = Vector3(-6.8, 7.5, 6.0)
    security_camera_2.rotation_degrees.y = 120.0
    security_camera_2.current_yaw = 0.0
    security_camera_2.current_pitch = -25.0
    add_child(security_camera_2)

    # 5. Multi-camera CCTV Console Station
    camera_station = CCTVStation.new()
    camera_station.position = Vector3(5.2, 0, 4.0)
    camera_station.rotation_degrees.y = 180.0
    camera_station.register_camera(security_camera)
    camera_station.register_camera(security_camera_2)
    add_child(camera_station)

    # 6. Quantum Kinetic Lift (Ascends ONLY when unobserved!)
    quantum_lift = QuantumPlatform.new()
    quantum_lift.position = Vector3(-7.5, 0, 10.0)
    quantum_lift.move_distance = 6.0
    quantum_lift.move_speed = 3.5
    add_child(quantum_lift)
    if ObservationManager.instance:
        ObservationManager.instance.register_observable(quantum_lift)

    # 7. Sub-Terminal 04 (Across Bridge Maintenance Override)
    override_terminal = Terminal.new()
    override_terminal.terminal_id = "TERM_MAINTENANCE"
    override_terminal.prompt_message = "Press [E] to Access Maintenance Terminal"
    override_terminal.header_text = "MAINTENANCE TERMINAL // GATE 07"
    override_terminal.log_message = "STATUS: GATE LOCKED\nEXECUTE OVERRIDE TO PROCEED"
    override_terminal.position = Vector3(-4.5, 0, -22.0)
    override_terminal.rotation_degrees.y = 90.0
    add_child(override_terminal)

    # 8. Observable Security Gate 07 (at Z = -32.0)
    security_door = ObservableDoor.new()
    security_door.position = Vector3(0, 0, -32.0)
    add_child(security_door)
    if ObservationManager.instance:
        ObservationManager.instance.register_observable(security_door)

    # 9. Final Central WATCHER Terminal (Inside Core Room at Z = -45.0)
    final_terminal = Terminal.new()
    final_terminal.terminal_id = "TERM_WATCHER_CORE"
    final_terminal.prompt_message = "Press [E] to Interface with WATCHER Core"
    final_terminal.header_text = "CENTRAL SURVEILLANCE NEXUS: WATCHER"
    final_terminal.log_message = "CORE READY FOR CONVERGENCE"
    final_terminal.position = Vector3(0, 0, -44.5)
    add_child(final_terminal)

    # 10. Lore Datapads scattered across the district
    _spawn_datapads()

func _spawn_datapads() -> void:
    # Datapad 1: In the South plaza near the curb
    var pad1 = Datapad.new()
    pad1.datapad_id = "SHARD-01"
    pad1.log_title = "INCIDENT REPORT: THE BLINK ANOMALY"
    pad1.log_author = "DR. A. VANCE // ARCHIVE ENGR"
    pad1.log_body = "It started with the streetlamps on 4th Ave.\n\nWhen I looked away, the fixtures changed from halogen to LED arrays. I timed it: exactly 220 milliseconds—the length of a human blink.\n\nThe system isn't simulating a physical world that runs in the background. It only renders when a sensory feed confirms an observer is active. Everything else dissolves into latent RAM.\n\nGod help us if all the cameras go down at once."
    pad1.position = Vector3(-4.0, 0.05, 16.5)
    add_child(pad1)
    datapads.append(pad1)

    # Datapad 2: Elevated Catwalk overlook (reached via Quantum Lift)
    var pad2 = Datapad.new()
    pad2.datapad_id = "SHARD-02"
    pad2.log_title = "RESEARCH MEMO: ANCHORING WAVE FUNCTIONS"
    pad2.log_author = "CHIEF ARCHITECT KHALIL"
    pad2.log_body = "We discovered that mechanical surveillance produces the exact same collapse as conscious organic vision.\n\nBy aiming CAM-01 directly at the chasm lattice, the photons from the lens lock the bridge in physical phase space. As long as the camera feeds data into WATCHER, the bridge cannot decay into probability fog.\n\nObservation is not just passive recording. In Glitch City, observation is the fundamental architectural resource."
    pad2.position = Vector3(-7.5, 6.05, 10.0)
    add_child(pad2)
    datapads.append(pad2)

    # Datapad 3: Across the Chasm near Gate 07
    var pad3 = Datapad.new()
    pad3.datapad_id = "SHARD-03"
    pad3.log_title = "WATCHER CORE DECREE: MEMORY CONSERVATION"
    pad3.log_author = "WATCHER SUBROUTINE 00"
    pad3.log_body = "CRITICAL DIRECTIVE:\n\nSimulating 14 million citizens in full detail exceeds current entropy budgets.\n\nEffective immediately: Objects, corridors, and structures not currently under optical confirmation shall have their collision and meshes pruned from active matrix.\n\nReality will be synthesized strictly on demand."
    pad3.position = Vector3(4.2, 0.05, -20.0)
    add_child(pad3)
    datapads.append(pad3)
