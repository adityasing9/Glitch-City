shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 base_color : source_color = vec4(0.0, 0.85, 1.0, 0.8);
uniform vec4 glitch_color : source_color = vec4(1.0, 0.2, 0.2, 0.5);
uniform float stability : hint_range(0.0, 1.0) = 1.0;
uniform float grid_scale : hint_range(1.0, 50.0) = 16.0;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 grid_uv = fract(UV * grid_scale);
    float grid_line = step(0.08, grid_uv.x) * step(0.08, grid_uv.y);
    float grid = 1.0 - grid_line;
    
    // Wave pulse along the surface
    float wave = sin(UV.y * 20.0 - TIME * pulse_speed) * 0.5 + 0.5;
    
    // Noise dissolve when stability drops
    float noise = hash(floor(UV * 25.0) + vec2(floor(TIME * 8.0)));
    
    if (stability < 0.99) {
        if (noise > stability) {
            discard;
        }
    }
    
    vec4 current_color = mix(glitch_color, base_color, stability);
    
    // Rim lighting
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.5);
    
    ALBEDO = current_color.rgb;
    EMISSION = current_color.rgb * (grid * 2.0 + wave * 0.6 + fresnel * 1.5) * (0.5 + 0.5 * stability);
    ALPHA = current_color.a * (0.4 + grid * 0.5 + fresnel * 0.5) * clamp(stability * 1.5, 0.0, 1.0);
    ROUGHNESS = 0.2;
    METALLIC = 0.5;
}
