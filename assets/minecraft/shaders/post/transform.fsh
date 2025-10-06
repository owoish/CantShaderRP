// slightly controllable camera
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <minecraft:globals.glsl>

uniform sampler2D DiffuseSampler;

in vec2 texCoord;

out vec4 fragColor;
flat in mat4 projection;
flat in mat4 projInv;
flat in mat3 tbn;

void main() {
    const float zoom = 1.0; // lower values = higher rotation angles, but lower fov and quality
    vec2 transformed = texCoord * zoom;
    
    
    vec4 homog = projInv * vec4(transformed, -1.0, 1.0);
    vec3 near = homog.xyz / homog.w;

    if (!(gl_FragCoord.x<42 && gl_FragCoord.y<floor(ScreenSize.y*0.6)+1 && gl_FragCoord.y>floor(ScreenSize.y*0.6))) {
        near = tbn * near;
    }

    homog = projection * vec4(near, 1.0);
    transformed = homog.xy / homog.w;

    transformed = transformed * 0.5 + 0.5;
/*
    if (transformed.y <= 1.0 / OutSize.y) {
        transformed.y = 1.0 / OutSize.y;
    }
*/
    fragColor = texture(DiffuseSampler, transformed);
}
