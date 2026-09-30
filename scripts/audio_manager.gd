class_name AudioManager
extends Node

static var instance: AudioManager

var ambient_player: AudioStreamPlayer
var synth_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var servo_player: AudioStreamPlayer
var glitch_player: AudioStreamPlayer

var sfx_beep: AudioStreamWAV
var sfx_glitch: AudioStreamWAV
var sfx_servo: AudioStreamWAV
var sfx_success: AudioStreamWAV
var sfx_step: AudioStreamWAV
var sfx_terminal: AudioStreamWAV
var sfx_drone: AudioStreamWAV
var sfx_flashlight: AudioStreamWAV
var sfx_datapad: AudioStreamWAV
var sfx_synth_arp: AudioStreamWAV

func _ready() -> void:
    instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    
    _generate_all_sounds()
    
    ambient_player = AudioStreamPlayer.new()
    ambient_player.stream = sfx_drone
    ambient_player.volume_db = -12.0
    ambient_player.bus = "Master"
    add_child(ambient_player)
    ambient_player.play()
    
    synth_player = AudioStreamPlayer.new()
    synth_player.stream = sfx_synth_arp
    synth_player.volume_db = -14.0
    synth_player.bus = "Master"
    add_child(synth_player)
    synth_player.play()
    
    sfx_player = AudioStreamPlayer.new()
    sfx_player.bus = "Master"
    add_child(sfx_player)
    
    servo_player = AudioStreamPlayer.new()
    servo_player.stream = sfx_servo
    servo_player.volume_db = -8.0
    servo_player.bus = "Master"
    add_child(servo_player)
    
    glitch_player = AudioStreamPlayer.new()
    glitch_player.stream = sfx_glitch
    glitch_player.volume_db = -6.0
    glitch_player.bus = "Master"
    add_child(glitch_player)

func _generate_all_sounds() -> void:
    sfx_beep = _create_tone(880.0, 0.12, 0.6, 22050)
    sfx_terminal = _create_tone(1200.0, 0.08, 0.5, 22050)
    sfx_glitch = _create_glitch_sound(0.28, 22050)
    sfx_servo = _create_servo_sound(0.5, 22050)
    sfx_success = _create_chord([440.0, 554.37, 659.25, 830.61], 1.2, 22050)
    sfx_step = _create_step_sound(0.1, 22050)
    sfx_drone = _create_ambient_drone(4.0, 22050)
    sfx_flashlight = _create_click_sound(0.06, 22050)
    sfx_datapad = _create_chord([587.33, 880.0, 1174.66], 0.35, 22050)
    sfx_synth_arp = _create_synth_music(8.0, 22050)

func play_beep(pitch_scale: float = 1.0) -> void:
    _play_oneshot(sfx_beep, -4.0, pitch_scale)

func play_terminal() -> void:
    _play_oneshot(sfx_terminal, -6.0, randf_range(0.9, 1.1))

func play_flashlight() -> void:
    _play_oneshot(sfx_flashlight, -2.0, randf_range(0.95, 1.05))

func play_datapad() -> void:
    _play_oneshot(sfx_datapad, -4.0, 1.0)

func play_glitch() -> void:
    if glitch_player and not glitch_player.playing:
        glitch_player.pitch_scale = randf_range(0.85, 1.25)
        glitch_player.play()

func play_success() -> void:
    _play_oneshot(sfx_success, -2.0, 1.0)

func play_footstep() -> void:
    _play_oneshot(sfx_step, -16.0, randf_range(0.8, 1.2))

func start_servo() -> void:
    if servo_player and not servo_player.playing:
        servo_player.play()

func stop_servo() -> void:
    if servo_player and servo_player.playing:
        servo_player.stop()

func set_music_intensity(cctv_mode: bool) -> void:
    if synth_player:
        var target_vol = -8.0 if cctv_mode else -14.0
        var tween = create_tween()
        tween.tween_property(synth_player, "volume_db", target_vol, 0.5)

func _play_oneshot(sound: AudioStreamWAV, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    var p = AudioStreamPlayer.new()
    p.stream = sound
    p.volume_db = volume_db
    p.pitch_scale = pitch
    p.bus = "Master"
    add_child(p)
    p.finished.connect(p.queue_free)
    p.play()

func _create_tone(freq: float, duration: float, volume: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var env = 1.0 - (float(i) / float(num_samples))
        var sample_val = sin(2.0 * PI * freq * t) * env * volume
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_click_sound(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var env = pow(1.0 - (float(i) / float(num_samples)), 4.0)
        var pulse = sin(2.0 * PI * 2400.0 * t) * env * 0.9
        var int_val = int(clamp(pulse, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
        
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_glitch_sound(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    var current_val = 0.0
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var env = 1.0 - (float(i) / float(num_samples))
        if i % 12 == 0:
            current_val = randf_range(-0.8, 0.8)
        var buzz = sin(2.0 * PI * 110.0 * t) * 0.4
        var sample_val = (current_val + buzz) * env * 0.8
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_servo_sound(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var stepper = sin(2.0 * PI * 340.0 * t) * 0.3 + sin(2.0 * PI * 680.0 * t) * 0.2
        var hum = sin(2.0 * PI * 60.0 * t) * 0.2
        var sample_val = (stepper + hum) * 0.4
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin = 0
    stream.loop_end = num_samples
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_chord(freqs: Array, duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var progress = float(i) / float(num_samples)
        var env = pow(1.0 - progress, 1.5)
        var mix = 0.0
        for f in freqs:
            mix += sin(2.0 * PI * float(f) * t)
        mix = (mix / float(freqs.size())) * env * 0.7
        var int_val = int(clamp(mix, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_step_sound(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var env = pow(1.0 - (float(i) / float(num_samples)), 3.0)
        var thud = sin(2.0 * PI * 80.0 * t) * 0.7 + (randf_range(-0.3, 0.3) * 0.3)
        var sample_val = thud * env * 0.5
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_ambient_drone(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var sub = sin(2.0 * PI * 55.0 * t) * 0.4
        var fifth = sin(2.0 * PI * 82.4 * t) * 0.25
        var octave = sin(2.0 * PI * 110.0 * t + sin(2.0 * PI * 0.5 * t)) * 0.15
        var sample_val = (sub + fifth + octave) * 0.5
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
    
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin = 0
    stream.loop_end = num_samples
    stream.stereo = false
    stream.data = bytes
    return stream

func _create_synth_music(duration: float, sample_rate: int) -> AudioStreamWAV:
    var num_samples = int(duration * sample_rate)
    var bytes = PackedByteArray()
    bytes.resize(num_samples * 2)
    
    var notes = [110.0, 130.81, 146.83, 164.81, 196.0, 164.81, 146.83, 130.81] # A minor pentatonic synth loop
    var note_duration = duration / float(notes.size())
    
    for i in range(num_samples):
        var t = float(i) / float(sample_rate)
        var note_idx = int(t / note_duration) % notes.size()
        var note_freq = notes[note_idx]
        var note_t = fmod(t, note_duration)
        var env = pow(1.0 - (note_t / note_duration), 1.8)
        
        # Cyberpunk synth bass + soft sawtooth harmonic
        var bass = sin(2.0 * PI * note_freq * t) * 0.5
        var arp = (sin(2.0 * PI * (note_freq * 2.0) * t) + sin(2.0 * PI * (note_freq * 3.0) * t) * 0.3) * 0.3
        var sample_val = (bass + arp) * env * 0.35
        var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, int_val)
        
    var stream = AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin = 0
    stream.loop_end = num_samples
    stream.stereo = false
    stream.data = bytes
    return stream
