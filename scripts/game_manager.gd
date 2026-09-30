class_name GameManager
extends Node

enum GameState {
    TITLE,
    PLAYING,
    IN_CCTV,
    PAUSED,
    ENDING
}

var current_state: GameState = GameState.TITLE

var player: Player
var level: LevelDistrict
var hud: HUD
var active_cctv_camera: SecurityCamera

var title_screen: TitleScreen
var pause_menu: PauseMenu
var ending_screen: EndingScreen

var bridge_permanently_locked: bool = false
var gate_unlocked: bool = false
var gate_opened: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func setup_references(p_player: Player, p_level: LevelDistrict, p_hud: HUD) -> void:
    player = p_player
    level = p_level
    hud = p_hud
    
    _connect_level_events()
    _connect_player_events()
    _show_title_screen()

func _connect_level_events() -> void:
    if not level:
        return
        
    if level.camera_station:
        level.camera_station.station_accessed.connect(_on_cctv_station_accessed)
        
    if level.security_camera:
        level.security_camera.locked_target_changed.connect(_on_camera_target_changed)
        
    if level.override_terminal:
        level.override_terminal.interacted.connect(_on_override_terminal_interacted)
        
    if level.final_terminal:
        level.final_terminal.interacted.connect(_on_final_terminal_interacted)
        
    if level.security_door:
        level.security_door.door_opened.connect(_on_security_door_opened)

func _connect_player_events() -> void:
    if not player:
        return
        
    player.interaction_prompt_changed.connect(func(prompt):
        if current_state == GameState.PLAYING and hud:
            hud.set_prompt(prompt)
    )
    
    player.player_fell_in_abyss.connect(func():
        if hud:
            hud.set_prompt("REALITY COLLAPSE - RESPAWNED")
    )

func _show_title_screen() -> void:
    current_state = GameState.TITLE
    if player:
        player.lock_player(true)
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    title_screen = TitleScreen.new()
    title_screen.start_game_requested.connect(_on_start_game)
    add_child(title_screen)

func _on_start_game() -> void:
    current_state = GameState.PLAYING
    if player:
        player.lock_player(false)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    if hud:
        hud.set_objective("Cross the fractured district ahead. Note: Anything unobserved dissolves.")

func _input(event: InputEvent) -> void:
    if current_state == GameState.TITLE or current_state == GameState.ENDING:
        return
        
    if event.is_action_just_pressed("pause"):
        if current_state == GameState.IN_CCTV:
            _exit_cctv_mode()
        elif current_state == GameState.PLAYING:
            _pause_game()
        elif current_state == GameState.PAUSED:
            _resume_game()
            
    if current_state == GameState.IN_CCTV:
        if event.is_action_just_pressed("interact") or event.is_action_just_pressed("ui_accept"):
            _exit_cctv_mode()

func _physics_process(delta: float) -> void:
    if current_state == GameState.IN_CCTV and active_cctv_camera:
        _handle_cctv_input(delta)

func _handle_cctv_input(delta: float) -> void:
    var yaw_in = 0.0
    var pitch_in = 0.0
    
    if Input.is_action_pressed("move_left"):
        yaw_in += 1.0
    if Input.is_action_pressed("move_right"):
        yaw_in -= 1.0
    if Input.is_action_pressed("move_forward"):
        pitch_in += 1.0
    if Input.is_action_pressed("move_backward"):
        pitch_in -= 1.0
        
    active_cctv_camera.pan_tilt(yaw_in, pitch_in, delta)

func _on_cctv_station_accessed(sec_cam: SecurityCamera) -> void:
    current_state = GameState.IN_CCTV
    active_cctv_camera = sec_cam
    
    if player:
        player.lock_player(true)
        
    sec_cam.set_camera_view_active(true)
    
    if hud:
        hud.set_cctv_mode(true)
        hud.set_objective("Aim CAM-01 at the Quantum Bridge to lock reality matrix.")

func _exit_cctv_mode() -> void:
    if current_state != GameState.IN_CCTV:
        return
        
    current_state = GameState.PLAYING
    
    if active_cctv_camera:
        active_cctv_camera.set_camera_view_active(false)
        active_cctv_camera = null
        
    if player:
        player.lock_player(false)
        if player.camera:
            player.camera.current = true
            
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    if hud:
        hud.set_cctv_mode(false)
        if bridge_permanently_locked:
            hud.set_objective("Bridge is observed & stabilized! Cross to Sector 07 Gateway.")
        else:
            hud.set_objective("Return to CCTV console to lock the bridge in place.")

func _on_camera_target_changed(has_target: bool, target_name: String) -> void:
    if hud:
        hud.update_cctv_target(has_target, target_name)
        
    if has_target and "bridge" in target_name.to_lower():
        bridge_permanently_locked = true
        if AudioManager.instance:
            AudioManager.instance.play_beep(1.6)

func _on_override_terminal_interacted(_terminal_id: String) -> void:
    if not gate_unlocked:
        gate_unlocked = true
        level.override_terminal.set_log("OVERRIDE EXECUTED.\nGATE 07 READY TO MANIFEST.\nLOOK AWAY TO ALLOW SHIFT.", true)
        
        if level.security_door:
            level.security_door.unlock_door()
            
        if hud:
            hud.set_objective("LOOK AWAY from Gate 07 so the system can redefine reality and open it.")
            
        if level.sign_billboard:
            level.sign_billboard.trigger_story_advance()

func _on_security_door_opened() -> void:
    gate_opened = true
    if hud:
        hud.set_objective("Gate 07 shifted open! Proceed into the Inner Core to interface with WATCHER.")

func _on_final_terminal_interacted(_terminal_id: String) -> void:
    current_state = GameState.ENDING
    if player:
        player.lock_player(true)
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    if hud:
        hud.visible = false
        
    ending_screen = EndingScreen.new()
    ending_screen.replay_requested.connect(_on_restart_game)
    add_child(ending_screen)

func _pause_game() -> void:
    current_state = GameState.PAUSED
    get_tree().paused = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    if not pause_menu:
        pause_menu = PauseMenu.new()
        pause_menu.resume_requested.connect(_resume_game)
        pause_menu.restart_requested.connect(_on_restart_game)
        add_child(pause_menu)
    pause_menu.show()

func _resume_game() -> void:
    current_state = GameState.PLAYING
    get_tree().paused = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    if pause_menu:
        pause_menu.hide()

func _on_restart_game() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()
