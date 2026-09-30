shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_density : hint_range(50.0, 800.0) = 300.0;
uniform float scanline_alpha : hint_range(0.0, 0.5) = 0.05;
uniform float color_aberration : hint_range(0.0, 0.05) = 0.005;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    if (glitch_intensity > 0.001) {
        // Horizontal glitch slices
        float slice_y = floor(uv.y * 30.0);
        float slice_noise = random(vec2(slice_y, floor(TIME * 24.0)));
        if (slice_noise < glitch_intensity * 0.7) {
            float shift = (random(vec2(slice_noise, TIME)) - 0.5) * 0.08 * glitch_intensity;
            uv.x += shift;
        }
        
        // Fine glitch lines
        float fine_y = floor(uv.y * 180.0);
        float fine_noise = random(vec2(fine_y, floor(TIME * 60.0)));
        if (fine_noise < glitch_intensity * 0.4) {
            uv.x += (fine_noise - 0.5) * 0.03 * glitch_intensity;
        }
    }
    
    // Chromatic aberration
    float ca = color_aberration + glitch_intensity * 0.02;
    vec4 col_r = texture(screen_texture, vec2(uv.x + ca, uv.y));
    vec4 col_g = texture(screen_texture, uv);
    vec4 col_b = texture(screen_texture, vec2(uv.x - ca, uv.y));
    
    vec4 color = vec4(col_r.r, col_g.g, col_b.b, 1.0);
    
    // Scanlines
    float scanline = sin(uv.y * scanline_density * 3.14159) * 0.5 + 0.5;
    color.rgb -= scanline * scanline_alpha;
    
    // Vignette
    vec2 dist = (uv - 0.5) * 1.25;
    float vignette = 1.0 - dot(dist, dist);
    color.rgb *= clamp(vignette, 0.2, 1.0);
    
    // Occasional static noise burst
    if (glitch_intensity > 0.1) {
        float noise = random(uv + vec2(TIME * 15.0, 0.0));
        color.rgb = mix(color.rgb, vec3(noise), glitch_intensity * 0.25);
    }
    
    COLOR = color;
}
