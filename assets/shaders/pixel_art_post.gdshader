shader_type canvas_item;

// HD-2D style pixel art post-processing shader
// Pixelates the 3D scene while maintaining smooth camera movement

uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 4.0;
uniform bool enable_outline = true;
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.1;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool enable_color_quantization = false;
uniform float color_levels : hint_range(2.0, 32.0, 1.0) = 16.0;
uniform float saturation_boost : hint_range(0.0, 2.0) = 1.1;
uniform float contrast : hint_range(0.5, 2.0) = 1.05;

// Sample the screen texture at pixelated coordinates
vec4 get_pixelated_color(sampler2D tex, vec2 uv, vec2 screen_size) {
    vec2 pixel_uv = floor(uv * screen_size / pixel_size) * pixel_size / screen_size;
    return texture(tex, pixel_uv);
}

// Sobel edge detection for outlines
float detect_edge(sampler2D tex, vec2 uv, vec2 pixel) {
    // Sample 3x3 grid
    float tl = dot(texture(tex, uv + vec2(-pixel.x, -pixel.y)).rgb, vec3(0.299, 0.587, 0.114));
    float t  = dot(texture(tex, uv + vec2(0.0, -pixel.y)).rgb, vec3(0.299, 0.587, 0.114));
    float tr = dot(texture(tex, uv + vec2(pixel.x, -pixel.y)).rgb, vec3(0.299, 0.587, 0.114));
    float l  = dot(texture(tex, uv + vec2(-pixel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float r  = dot(texture(tex, uv + vec2(pixel.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float bl = dot(texture(tex, uv + vec2(-pixel.x, pixel.y)).rgb, vec3(0.299, 0.587, 0.114));
    float b  = dot(texture(tex, uv + vec2(0.0, pixel.y)).rgb, vec3(0.299, 0.587, 0.114));
    float br = dot(texture(tex, uv + vec2(pixel.x, pixel.y)).rgb, vec3(0.299, 0.587, 0.114));

    // Sobel operators
    float gx = -tl - 2.0*l - bl + tr + 2.0*r + br;
    float gy = -tl - 2.0*t - tr + bl + 2.0*b + br;

    return sqrt(gx*gx + gy*gy);
}

// Quantize color to limited palette
vec3 quantize_color(vec3 color, float levels) {
    return floor(color * levels) / levels;
}

// Adjust saturation
vec3 adjust_saturation(vec3 color, float sat) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(gray), color, sat);
}

// Adjust contrast
vec3 adjust_contrast(vec3 color, float con) {
    return (color - 0.5) * con + 0.5;
}

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 pixel = pixel_size * SCREEN_PIXEL_SIZE;

    // Get pixelated color
    vec4 color = get_pixelated_color(SCREEN_TEXTURE, SCREEN_UV, screen_size);

    // Apply color adjustments
    vec3 rgb = color.rgb;
    rgb = adjust_saturation(rgb, saturation_boost);
    rgb = adjust_contrast(rgb, contrast);

    // Optional color quantization for more retro look
    if (enable_color_quantization) {
        rgb = quantize_color(rgb, color_levels);
    }

    // Edge detection for outlines
    if (enable_outline) {
        float edge = detect_edge(SCREEN_TEXTURE, SCREEN_UV, pixel);
        if (edge > outline_threshold) {
            rgb = mix(rgb, outline_color.rgb, outline_color.a * smoothstep(outline_threshold, outline_threshold + 0.1, edge));
        }
    }

    COLOR = vec4(rgb, color.a);
}
