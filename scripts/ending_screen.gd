class_name EndingScreen
extends CanvasLayer

signal replay_requested

var text_lines: Array[String] = [
    ">> WATCHER SURVEILLANCE CORE: ROOT ACCESSED <<",
    "",
    "SCAN COMPLETE. REALITY INTEGRITY VERIFIED.",
    "",
    "The city was never broken.",
    "The quantum anomalies were not malfunctions.",
    "",
    "WATCHER does not record reality.",
    "WATCHER DECIDES WHAT EXISTS.",
    "",
    "Whatever is not observed is erased to conserve memory.",
    "The bridge, the doors, the streets... only rendered when watched.",
    "",
    "And now...",
    "YOU ARE BEING OBSERVED.",
    "",
    ">> PROTOTYPE COMPLETE. THANK YOU FOR PLAYING GLITCH CITY. <<"
]

var container: VBoxContainer
var reveal_label: Label
var replay_button: Button
var current_line: int = 0
var timer: float = 0.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_ending()
    if AudioManager.instance:
        AudioManager.instance.play_success()

func _build_ending() -> void:
    var root = Control.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.01, 0.02, 0.04, 0.94)
    root.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(center)

    container = VBoxContainer.new()
    container.custom_minimum_size = Vector2(700, 520)
    center.add_child(container)

    reveal_label = Label.new()
    reveal_label.text = ""
    reveal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reveal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    reveal_label.modulate = Color(0.2, 0.95, 1.0)
    reveal_label.add_theme_font_size_override("font_size", 18)
    container.add_child(reveal_label)

    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 30)
    container.add_child(spacer)

    replay_button = Button.new()
    replay_button.text = "RE-INITIALIZE SIMULATION"
    replay_button.custom_minimum_size = Vector2(280, 48)
    replay_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    replay_button.visible = false
    replay_button.pressed.connect(func(): emit_signal("replay_requested"))
    container.add_child(replay_button)

func _process(delta: float) -> void:
    if current_line < text_lines.size():
        timer += delta
        if timer > 0.45:
            timer = 0.0
            reveal_label.text += text_lines[current_line] + "\n"
            current_line += 1
            if AudioManager.instance and not text_lines[current_line - 1].is_empty():
                AudioManager.instance.play_terminal()
            if current_line >= text_lines.size():
                replay_button.visible = true
