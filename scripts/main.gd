class_name Main
extends Node3D

var audio_mgr: AudioManager
var obs_mgr: ObservationManager
var level: LevelDistrict
var player: Player
var hud: HUD
var game_mgr: GameManager

func _ready() -> void:
    _setup_environment()
    _setup_systems()

func _setup_environment() -> void:
    var world_env = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.02, 0.03, 0.05)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.04, 0.05, 0.08)
    env.ambient_light_energy = 1.0
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.glow_enabled = true
    env.glow_intensity = 0.6
    env.glow_bloom = 0.2
    
    # Fog for atmospheric depth
    env.fog_enabled = true
    env.fog_light_color = Color(0.04, 0.07, 0.12)
    env.fog_density = 0.015
    env.fog_sky_affect = 0.5
    
    world_env.environment = env
    add_child(world_env)
    
    # Moon/dusk directional rim light
    var dir_light = DirectionalLight3D.new()
    dir_light.rotation_degrees = Vector3(-45, -30, 0)
    dir_light.light_color = Color(0.1, 0.2, 0.35)
    dir_light.light_energy = 0.4
    dir_light.shadow_enabled = true
    add_child(dir_light)

func _setup_systems() -> void:
    # 1. Audio Manager
    audio_mgr = AudioManager.new()
    audio_mgr.name = "AudioManager"
    add_child(audio_mgr)

    # 2. Observation Manager
    obs_mgr = ObservationManager.new()
    obs_mgr.name = "ObservationManager"
    add_child(obs_mgr)

    # 3. Level District
    level = LevelDistrict.new()
    level.name = "LevelDistrict"
    add_child(level)

    # 4. Player (Spawn in South Plaza, facing North toward the chasm)
    player = Player.new()
    player.name = "Player"
    player.position = Vector3(0, 1.2, 16.0)
    player.rotation_degrees.y = 180.0 # Facing North (Z = -6.0)
    add_child(player)

    # 5. UI HUD
    hud = HUD.new()
    hud.name = "HUD"
    add_child(hud)

    # 6. Game Manager
    game_mgr = GameManager.new()
    game_mgr.name = "GameManager"
    add_child(game_mgr)
    game_mgr.setup_references(player, level, hud)
