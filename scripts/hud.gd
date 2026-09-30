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

var cctv_overlay: Control
var cctv_rec_label: Label
var cctv_status_label: Label
var cctv_target_label: Label
var cctv_controls_hint: Label

var glitch_rect: ColorRect
var glitch_material: ShaderMaterial

var in_cctv_mode: bool = false
var time_elapsed: float = 0.0

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
    sys_label.text = "SYS // WATCHER PROTOCOL v4.9  |  SECTOR 07"
    sys_label.modulate = Color(0.1, 0.85, 1.0, 0.8)
    top_left.add_child(sys_label)

    coherence_label = Label.new()
    coherence_label.text = "REALITY COHERENCE: 100.0%"
    coherence_label.modulate = Color(0.2, 1.0, 0.6)
    top_left.add_child(coherence_label)

    coherence_bar = ProgressBar.new()
    coherence_bar.custom_minimum_size = Vector2(220, 8)
    coherence_bar.max_value = 1.0
    coherence_bar.value = 1.0
    coherence_bar.show_percentage = false
    top_left.add_child(coherence_bar)

    # Top-Right Objective Banner
    var top_right = PanelContainer.new()
    top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    top_right.offset_left = -420
    top_right.offset_top = 25
    top_right.offset_right = -30
    top_right.offset_bottom = 85
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
    prompt_container.offset_left = -220
    prompt_container.offset_top = -140
    prompt_container.offset_right = 220
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

func _build_cctv_overlay(parent: Control) -> void:
    cctv_overlay = Control.new()
    cctv_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    cctv_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cctv_overlay.visible = false
    parent.add_child(cctv_overlay)

    # Scanline corners / frame
    var frame_l = ColorRect.new()
    frame_l.position = Vector2(20, 20)
    frame_l.size = Vector2(30, 3)
    frame_l.color = Color(0.2, 0.9, 1.0, 0.7)
    cctv_overlay.add_child(frame_l)

    var frame_r = ColorRect.new()
    frame_r.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    frame_r.position = Vector2(-50, 20)
    frame_r.size = Vector2(30, 3)
    frame_r.color = Color(0.2, 0.9, 1.0, 0.7)
    cctv_overlay.add_child(frame_r)

    cctv_rec_label = Label.new()
    cctv_rec_label.text = "● REC [LIVE FEED] // CAM-01 (HIGH ANGLE SECTOR 07)"
    cctv_rec_label.position = Vector2(60, 40)
    cctv_rec_label.modulate = Color(1.0, 0.2, 0.3)
    cctv_overlay.add_child(cctv_rec_label)

    cctv_status_label = Label.new()
    cctv_status_label.text = "OPTICAL MATRIX: SEARCHING TARGET..."
    cctv_status_label.position = Vector2(60, 70)
    cctv_status_label.modulate = Color(0.2, 0.9, 1.0)
    cctv_overlay.add_child(cctv_status_label)

    cctv_target_label = Label.new()
    cctv_target_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    cctv_target_label.offset_left = -300
    cctv_target_label.offset_top = 110
    cctv_target_label.offset_right = 300
    cctv_target_label.offset_bottom = 150
    cctv_target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cctv_target_label.text = ""
    cctv_target_label.modulate = Color(0.1, 1.0, 0.5)
    cctv_overlay.add_child(cctv_target_label)

    cctv_controls_hint = Label.new()
    cctv_controls_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    cctv_controls_hint.offset_left = -300
    cctv_controls_hint.offset_top = -80
    cctv_controls_hint.offset_right = 300
    cctv_controls_hint.offset_bottom = -40
    cctv_controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cctv_controls_hint.text = "[W / A / S / D] PAN CAMERA   |   [E / SPACE] DISENGAGE CONSOLE"
    cctv_controls_hint.modulate = Color(1.0, 0.8, 0.2)
    cctv_overlay.add_child(cctv_controls_hint)

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

func set_cctv_mode(active: bool) -> void:
    in_cctv_mode = active
    cctv_overlay.visible = active
    crosshair.visible = not active
    prompt_container.visible = false
    
    if active:
        set_glitch_intensity(0.25)
    else:
        set_glitch_intensity(0.1)

func update_cctv_target(has_target: bool, target_name: String) -> void:
    if has_target:
        cctv_status_label.text = "OPTICAL MATRIX: [LOCKED ON OBJECT]"
        cctv_status_label.modulate = Color(0.1, 1.0, 0.4)
        cctv_target_label.text = ">>> TARGET ACQUIRED: %s [REALITY STABILIZED] <<<" % target_name.to_upper()
    else:
        cctv_status_label.text = "OPTICAL MATRIX: SEARCHING (AIM TOWARD CHASM BRIDGE)..."
        cctv_status_label.modulate = Color(1.0, 0.7, 0.2)
        cctv_target_label.text = ""

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
