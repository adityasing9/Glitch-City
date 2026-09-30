class_name PauseMenu
extends CanvasLayer

signal resume_requested
signal restart_requested

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _build_menu()
    hide()

func _build_menu() -> void:
    var root = Control.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    var bg = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.02, 0.03, 0.05, 0.8)
    bg.gui_input.connect(func(ev):
        if ev is InputEventMouseButton and ev.pressed:
            emit_signal("resume_requested")
    )
    root.add_child(bg)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(center)

    var vbox = VBoxContainer.new()
    vbox.custom_minimum_size = Vector2(320, 260)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_child(vbox)

    var title = Label.new()
    title.text = "// SIMULATION SUSPENDED //"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.modulate = Color(0.1, 0.9, 1.0)
    vbox.add_child(title)

    var subtitle = Label.new()
    subtitle.text = "[ CLICK ANYWHERE OR PRESS ESC TO RESUME ]"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.modulate = Color(0.6, 0.8, 0.9)
    vbox.add_child(subtitle)

    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 15)
    vbox.add_child(spacer)

    var resume_btn = Button.new()
    resume_btn.text = "RESUME EXECUTION"
    resume_btn.custom_minimum_size = Vector2(260, 42)
    resume_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    resume_btn.pressed.connect(func(): emit_signal("resume_requested"))
    vbox.add_child(resume_btn)

    var restart_btn = Button.new()
    restart_btn.text = "RESTART SEQUENCE"
    restart_btn.custom_minimum_size = Vector2(260, 42)
    restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    restart_btn.pressed.connect(func(): emit_signal("restart_requested"))
    vbox.add_child(restart_btn)

    var quit_btn = Button.new()
    quit_btn.text = "ABORT TO DESKTOP"
    quit_btn.custom_minimum_size = Vector2(260, 42)
    quit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    quit_btn.pressed.connect(func(): get_tree().quit())
    vbox.add_child(quit_btn)
