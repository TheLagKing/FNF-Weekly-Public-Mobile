#pragma header

uniform float splitCount;
uniform float x;
uniform float y;
uniform float mirrored;  // 1.0 for true, 0.0 for false

void main() {
    vec2 uv = openfl_TextureCoordv;
    uv *= splitCount;
    uv.x += x;
    uv.y += y;
    
    uv.x = mix(uv.x, 1.0 - uv.x, mirrored); // interpolates based on mirrored being 0 or 1

    gl_FragColor = flixel_texture2D(bitmap, fract(uv)); 
}
