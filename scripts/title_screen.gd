class_name TitleScreen
extends CanvasLayer

signal start_game_requested

var panel: PanelContainer
var title_label: Label
var subtitle_label: Label
var start_button: Button

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_title()

func _build_title() -> void:
    var root = Control.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    # Dark background tint
    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.02, 0.03, 0.06, 0.88)
    root.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(center)

    var vbox = VBoxContainer.new()
    vbox.custom_minimum_size = Vector2(620, 480)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_child(vbox)

    # Title
    title_label = Label.new()
    title_label.text = "G L I T C H   C I T Y"
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 42)
    title_label.modulate = Color(0.1, 0.9, 1.0)
    vbox.add_child(title_label)

    # Subtitle
    subtitle_label = Label.new()
    subtitle_label.text = "// AN OBSERVATION-DRIVEN CYBERPUNK PUZZLE //"
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.modulate = Color(1.0, 0.2, 0.6)
    vbox.add_child(subtitle_label)

    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 30)
    vbox.add_child(spacer)

    # Core Rule Callout
    var quote_box = PanelContainer.new()
    var quote_vbox = VBoxContainer.new()
    quote_box.add_child(quote_vbox)
    
    var quote_title = Label.new()
    quote_title.text = "CORE LAW OF THE DISTRICT:"
    quote_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    quote_title.modulate = Color(1.0, 0.75, 0.2)
    quote_vbox.add_child(quote_title)

    var quote_body = Label.new()
    quote_body.text = "\"Anything that is not being observed can change.\nIf nobody watches something, the system is free to redefine it.\""
    quote_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    quote_body.modulate = Color(0.85, 0.9, 0.95)
    quote_vbox.add_child(quote_body)
    vbox.add_child(quote_box)

    var spacer2 = Control.new()
    spacer2.custom_minimum_size = Vector2(0, 20)
    vbox.add_child(spacer2)

    # Controls recap
    var ctrl_label = Label.new()
    ctrl_label.text = "CONTROLS:  [W/A/S/D] Move   |   [MOUSE] Look   |   [SHIFT] Sprint   |   [E] Interact / Use CCTV"
    ctrl_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ctrl_label.modulate = Color(0.6, 0.8, 0.9)
    vbox.add_child(ctrl_label)

    var spacer3 = Control.new()
    spacer3.custom_minimum_size = Vector2(0, 25)
    vbox.add_child(spacer3)

    # Start button
    start_button = Button.new()
    start_button.text = "INITIALIZE PROTOCOL  [START]"
    start_button.custom_minimum_size = Vector2(300, 48)
    start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    start_button.pressed.connect(_on_start_pressed)
    vbox.add_child(start_button)

func _on_start_pressed() -> void:
    if AudioManager.instance:
        AudioManager.instance.play_beep(1.4)
    emit_signal("start_game_requested")
    queue_free()
