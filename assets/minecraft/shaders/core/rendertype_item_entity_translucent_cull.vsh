#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat3 IViewRotMat;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

out float marker;
out vec4 position0;
out vec4 position1;
out vec4 position2;
out vec4 position3;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0); //vanilla behaviour

    vec4 col = texture(Sampler0, UV0); //检测顶点颜色值
    marker = col.rgb == vec3(76, 195, 86) / 255 ? 1.0 : 0.0; //并标记模型

    position0 = 
    position1 = 
    position2 = 
    position3 = vec4(0.0); //合法的连等符号

    sphericalVertexDistance = fog_spherical_distance(Position); //vanilla behaviour
    cylindricalVertexDistance = fog_cylindrical_distance(Position); //vanilla behaviour
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0); //vanilla behaviour
    texCoord0 = UV0; //vanilla behaviour
    //was     texCoord1 = UV1;
    //        texCoord2 = UV2;
    //不知道有什么用

    if (marker > 0.0) { //如果顶点被标记成功
        vec3 worldSpace = Position; //忽略
        switch (gl_VertexID % 4) {
            case 0: position0 = vec4(worldSpace, 1.0); break; //向各自的值写入对应的数据，反之为vec4(0)
            case 1: position1 = vec4(worldSpace, 1.0); break;
            case 2: position2 = vec4(worldSpace, 1.0); break;
            case 3: position3 = vec4(worldSpace, 1.0); break;
        }

        // TODO: better vertex positions
        vec2 bottomLeftCorner = vec2(-1.0); //最终屏幕坐标系范围为-1到1，左下到右上
        vec2 topRightCorner = vec2(1.0, 0.1);
        switch (gl_VertexID % 4) {
            case 0: gl_Position = vec4(bottomLeftCorner.x, topRightCorner.y,   -1, 1); break;
            case 1: gl_Position = vec4(bottomLeftCorner.x, bottomLeftCorner.y, -1, 1); break;
            case 2: gl_Position = vec4(topRightCorner.x,   bottomLeftCorner.y, -1, 1); break;
            case 3: gl_Position = vec4(topRightCorner.x,   topRightCorner.y,   -1, 1); break;
        } //放置顶点到屏幕空间，这会是给后处理传参的画布
    }
}