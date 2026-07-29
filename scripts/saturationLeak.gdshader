shader_type canvas_item;

// 0.0 = Gray/Black, 1.0 = Original
uniform float saturation : hint_range(0.0, 1.0) = 0.2;
// 0.0 = Black, 1.0 = Original
uniform float brightness : hint_range(0.0, 1.0) = 0.75;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray_color = vec3(luminance);
    vec3 desaturated = mix(gray_color, tex_color.rgb, saturation);
    COLOR.rgb = desaturated * brightness;
    COLOR.a = tex_color.a;
}