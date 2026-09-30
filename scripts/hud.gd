class_name HUD
extends CanvasLayer

var crosshair: Control
var reticle_center: ColorRect
var reticle_bracket_l: Label
var reticle_bracket_r: Label

var prompt_label: Label
var prompt_container: PanelContainer

var objective_label: Label
var coherence_label: Label
var coherence_bar: ProgressBar

# Scanner Telemetry
var scanner_container: PanelContainer
var scanner_label: Label

# CCTV Feed Overlay
var cctv_overlay: Control
var cctv_rec_label: Label
var cctv_status_label: Label
var cctv_target_label: Label
var cctv_controls_hint: Label
var cctv_channel_label: Label

# Datapad Reader Modal
var datapad_modal: Control
var datapad_title: Label
var datapad_author: Label
var datapad_body: Label
var datapad_close_hint: Label

var glitch_rect: ColorRect
var glitch_material: ShaderMaterial

var in_cctv_mode: bool = false
var datapad_active: bool = false
var time_elapsed: float = 0.0

signal datapad_dismissed

func _ready() -> void:
    _build_hud()
    
    if ObservationManager.instance:
        ObservationManager.instance.reality_coherence_updated.connect(_on_coherence_updated)
        ObservationManager.instance.glitch_triggered.connect(_on_glitch_triggered)

func _build_hud() -> void:
    # 1. Glitch Post-Process Screen Rect
    glitch_rect = ColorRect.new()
    glitch_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    glitch_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var shader = load("res://shaders/glitch_screen.gdshader")
    glitch_material = ShaderMaterial.new()
    glitch_material.shader = shader
    glitch_material.set_shader_parameter("glitch_intensity", 0.0)
    glitch_rect.material = glitch_material
    add_child(glitch_rect)

    # 2. Main HUD Container
    var root_control = Control.new()
    root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
    root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root_control)

    # Top-Left Telemetry Box
    var top_left = VBoxContainer.new()
    top_left.position = Vector2(30, 25)
    root_control.add_child(top_left)

    var sys_label = Label.new()
    sys_label.text = "SYS // WATCHER PROTOCOL v4.9  |  SECTOR 07  [F: FLASH]"
    sys_label.modulate = Color(0.1, 0.85, 1.0, 0.8)
    top_left.add_child(sys_label)

    coherence_label = Label.new()
    coherence_label.text = "REALITY COHERENCE: 100.0%"
    coherence_label.modulate = Color(0.2, 1.0, 0.6)
    top_left.add_child(coherence_label)

    coherence_bar = ProgressBar.new()
    coherence_bar.custom_minimum_size = Vector2(240, 8)
    coherence_bar.max_value = 1.0
    coherence_bar.value = 1.0
    coherence_bar.show_percentage = false
    top_left.add_child(coherence_bar)

    # Top-Right Objective Banner
    var top_right = PanelContainer.new()
    top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    top_right.offset_left = -440
    top_right.offset_top = 25
    top_right.offset_right = -30
    top_right.offset_bottom = 90
    root_control.add_child(top_right)

    var obj_vbox = VBoxContainer.new()
    top_right.add_child(obj_vbox)

    var obj_header = Label.new()
    obj_header.text = "CURRENT DIRECTIVE:"
    obj_header.modulate = Color(1.0, 0.7, 0.2)
    obj_vbox.add_child(obj_header)

    objective_label = Label.new()
    objective_label.text = "Investigate the quantum fracture ahead"
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.modulate = Color(0.9, 0.95, 1.0)
    obj_vbox.add_child(objective_label)

    # Scanner Telemetry Banner (Below crosshair)
    scanner_container = PanelContainer.new()
    scanner_container.set_anchors_preset(Control.PRESET_CENTER)
    scanner_container.offset_left = -260
    scanner_container.offset_top = 45
    scanner_container.offset_right = 260
    scanner_container.offset_bottom = 85
    scanner_container.visible = false
    root_control.add_child(scanner_container)

    scanner_label = Label.new()
    scanner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    scanner_label.modulate = Color(0.2, 0.9, 1.0)
    scanner_container.add_child(scanner_label)

    # Center Reticle / Crosshair
    crosshair = Control.new()
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    root_control.add_child(crosshair)

    reticle_center = ColorRect.new()
    reticle_center.custom_minimum_size = Vector2(4, 4)
    reticle_center.position = Vector2(-2, -2)
    reticle_center.color = Color(0.2, 0.9, 1.0, 0.8)
    crosshair.add_child(reticle_center)

    reticle_bracket_l = Label.new()
    reticle_bracket_l.text = "["
    reticle_bracket_l.position = Vector2(-16, -12)
    reticle_bracket_l.modulate = Color(0.2, 0.9, 1.0, 0.6)
    crosshair.add_child(reticle_bracket_l)

    reticle_bracket_r = Label.new()
    reticle_bracket_r.text = "]"
    reticle_bracket_r.position = Vector2(8, -12)
    reticle_bracket_r.modulate = Color(0.2, 0.9, 1.0, 0.6)
    crosshair.add_child(reticle_bracket_r)

    # Bottom Center Prompt
    prompt_container = PanelContainer.new()
    prompt_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt_container.offset_left = -260
    prompt_container.offset_top = -140
    prompt_container.offset_right = 260
    prompt_container.offset_bottom = -95
    prompt_container.visible = false
    root_control.add_child(prompt_container)

    prompt_label = Label.new()
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    prompt_label.modulate = Color(0.2, 1.0, 0.7)
    prompt_container.add_child(prompt_label)

    # 3. CCTV Feed Mode Overlay
    _build_cctv_overlay(root_control)
    
    # 4. Datapad Reader Modal
    _build_datapad_modal(root_control)

func _build_cctv_overlay(parent: Control) -> void:
    cctv_overlay = Control.new()
    cctv_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    cctv_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cctv_overlay.visible = false
    parent.add_child(cctv_overlay)

    # Corner brackets
    var frame_l = ColorRect.new()
    frame_l.position = Vector2(25, 25)
    frame_l.size = Vector2(40, 3)
    frame_l.color = Color(0.2, 0.9, 1.0, 0.8)
    cctv_overlay.add_child(frame_l)

    var frame_r = ColorRect.new()
    frame_r.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    frame_r.position = Vector2(-65, 25)
    frame_r.size = Vector2(40, 3)
    frame_r.color = Color(0.2, 0.9, 1.0, 0.8)
    cctv_overlay.add_child(frame_r)

    cctv_rec_label = Label.new()
    cctv_rec_label.text = "● REC [LIVE FEED] // HIGH SECURITY SURVEILLANCE"
    cctv_rec_label.position = Vector2(60, 40)
    cctv_rec_label.modulate = Color(1.0, 0.2, 0.3)
    cctv_overlay.add_child(cctv_rec_label)

    cctv_channel_label = Label.new()
    cctv_channel_label.text = "FEED: CAM-01 [CHASM BRIDGE]"
    cctv_channel_label.position = Vector2(60, 68)
    cctv_channel_label.modulate = Color(0.2, 0.9, 1.0)
    cctv_overlay.add_child(cctv_channel_label)

    cctv_status_label = Label.new()
    cctv_status_label.text = "OPTICAL MATRIX: SEARCHING TARGET..."
    cctv_status_label.position = Vector2(60, 96)
    cctv_status_label.modulate = Color(1.0, 0.75, 0.2)
    cctv_overlay.add_child(cctv_status_label)

    cctv_target_label = Label.new()
    cctv_target_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    cctv_target_label.offset_left = -320
    cctv_target_label.offset_top = 110
    cctv_target_label.offset_right = 320
    cctv_target_label.offset_bottom = 150
    cctv_target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cctv_target_label.text = ""
    cctv_target_label.modulate = Color(0.1, 1.0, 0.5)
    cctv_overlay.add_child(cctv_target_label)

    cctv_controls_hint = Label.new()
    cctv_controls_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    cctv_controls_hint.offset_left = -380
    cctv_controls_hint.offset_top = -80
    cctv_controls_hint.offset_right = 380
    cctv_controls_hint.offset_bottom = -40
    cctv_controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cctv_controls_hint.text = "[W/A/S/D] AIM CAMERA  |  [Q / 1 / 2] SWITCH CHANNEL  |  [E / SPACE] DISENGAGE"
    cctv_controls_hint.modulate = Color(1.0, 0.85, 0.2)
    cctv_overlay.add_child(cctv_controls_hint)

func _build_datapad_modal(parent: Control) -> void:
    datapad_modal = Control.new()
    datapad_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
    datapad_modal.visible = false
    parent.add_child(datapad_modal)

    var dim = ColorRect.new()
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.color = Color(0.01, 0.02, 0.05, 0.85)
    datapad_modal.add_child(dim)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    datapad_modal.add_child(center)

    var panel = PanelContainer.new()
    panel.custom_minimum_size = Vector2(640, 420)
    center.add_child(panel)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    datapad_title = Label.new()
    datapad_title.text = "ENCRYPTED MEMORY SHARD"
    datapad_title.add_theme_font_size_override("font_size", 20)
    datapad_title.modulate = Color(0.1, 0.9, 1.0)
    vbox.add_child(datapad_title)

    datapad_author = Label.new()
    datapad_author.text = "SOURCE: UNKNOWN"
    datapad_author.modulate = Color(1.0, 0.7, 0.2)
    vbox.add_child(datapad_author)

    var divider = ColorRect.new()
    divider.custom_minimum_size = Vector2(0, 2)
    divider.color = Color(0.2, 0.8, 1.0, 0.4)
    vbox.add_child(divider)

    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 15)
    vbox.add_child(spacer)

    datapad_body = Label.new()
    datapad_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    datapad_body.modulate = Color(0.9, 0.95, 1.0)
    vbox.add_child(datapad_body)

    var spacer2 = Control.new()
    spacer2.custom_minimum_size = Vector2(0, 25)
    vbox.add_child(spacer2)

    datapad_close_hint = Label.new()
    datapad_close_hint.text = "[ PRESS E OR ESC TO CLOSE ARCHIVE ]"
    datapad_close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    datapad_close_hint.modulate = Color(0.4, 1.0, 0.6)
    vbox.add_child(datapad_close_hint)

func _process(delta: float) -> void:
    time_elapsed += delta
    if in_cctv_mode:
        var blink = int(time_elapsed * 2.5) % 2 == 0
        cctv_rec_label.modulate = Color(1.0, 0.2, 0.3) if blink else Color(0.4, 0.1, 0.1)

func set_prompt(text: String) -> void:
    if text.is_empty():
        prompt_container.visible = false
        reticle_center.color = Color(0.2, 0.9, 1.0, 0.8)
        reticle_bracket_l.modulate = Color(0.2, 0.9, 1.0, 0.6)
        reticle_bracket_r.modulate = Color(0.2, 0.9, 1.0, 0.6)
    else:
        prompt_label.text = text
        prompt_container.visible = true
        reticle_center.color = Color(0.1, 1.0, 0.6, 1.0)
        reticle_bracket_l.modulate = Color(0.1, 1.0, 0.6, 1.0)
        reticle_bracket_r.modulate = Color(0.1, 1.0, 0.6, 1.0)

func set_objective(text: String) -> void:
    objective_label.text = text

func update_scanner(obj_name: String, state_text: String, observer_text: String) -> void:
    if obj_name.is_empty():
        scanner_container.visible = false
    else:
        scanner_container.visible = true
        scanner_label.text = "[ SCAN: %s | %s | %s ]" % [obj_name.to_upper(), state_text, observer_text]

func set_cctv_mode(active: bool, cam_id: String = "CAM-01") -> void:
    in_cctv_mode = active
    cctv_overlay.visible = active
    crosshair.visible = not active
    scanner_container.visible = false
    prompt_container.visible = false
    
    if active:
        cctv_channel_label.text = "FEED: %s" % cam_id
        set_glitch_intensity(0.25)
    else:
        set_glitch_intensity(0.1)

func set_cctv_channel_text(cam_id: String) -> void:
    if cctv_channel_label:
        cctv_channel_label.text = "FEED: %s" % cam_id

func update_cctv_target(has_target: bool, target_name: String) -> void:
    if has_target:
        cctv_status_label.text = "OPTICAL MATRIX: [LOCKED ON OBJECT]"
        cctv_status_label.modulate = Color(0.1, 1.0, 0.4)
        cctv_target_label.text = ">>> TARGET ACQUIRED: %s [REALITY STABILIZED] <<<" % target_name.to_upper()
    else:
        cctv_status_label.text = "OPTICAL MATRIX: SEARCHING (AIM TOWARD CHASM BRIDGE)..."
        cctv_status_label.modulate = Color(1.0, 0.7, 0.2)
        cctv_target_label.text = ""

func show_datapad(title_text: String, author_text: String, body_text: String) -> void:
    datapad_active = true
    datapad_title.text = title_text
    datapad_author.text = author_text
    datapad_body.text = body_text
    datapad_modal.visible = true
    crosshair.visible = false

func hide_datapad() -> void:
    datapad_active = false
    datapad_modal.visible = false
    crosshair.visible = true
    emit_signal("datapad_dismissed")

func _on_coherence_updated(coherence: float) -> void:
    coherence_bar.value = coherence
    coherence_label.text = "REALITY COHERENCE: %.1f%%" % (coherence * 100.0)
    if coherence > 0.8:
        coherence_label.modulate = Color(0.2, 1.0, 0.6)
    elif coherence > 0.5:
        coherence_label.modulate = Color(1.0, 0.7, 0.2)
    else:
        coherence_label.modulate = Color(1.0, 0.25, 0.25)

func _on_glitch_triggered(intensity: float) -> void:
    set_glitch_intensity(intensity)

func set_glitch_intensity(intensity: float) -> void:
    if glitch_material:
        glitch_material.set_shader_parameter("glitch_intensity", intensity)
        var tween = create_tween()
        tween.tween_property(glitch_material, "shader_parameter/glitch_intensity", 0.0, 0.4)
