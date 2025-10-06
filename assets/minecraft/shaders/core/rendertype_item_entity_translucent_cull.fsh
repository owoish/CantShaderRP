//modified by owoish
// slightly controllable camera
// https://github.com/JNNGL/vanilla-shaders

#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in float marker;
in float screen_marker;
in vec4 position0;
in vec4 position1;
in vec4 position2;
in vec4 position3;
in vec4 position0a;
in vec4 position1a;
in vec4 position2a;
in vec4 position3a;

out vec4 fragColor;

vec4 encodeInt(int i) {
    int s = int(i < 0) * 128;
    i = abs(i);
    int r = i % 256;
    i = i / 256;
    int g = i % 256;
    i = i / 256;
    int b = i % 256;
    return vec4(float(r) / 255.0, float(g) / 255.0, float(b + s) / 255.0, 1.0);
}

vec4 encodeFloat1024(float v) {
    v *= 1024.0;
    v = floor(v);
    return encodeInt(int(v));
}

vec4 encodeFloat(float v) {
    v *= 40000.0;
    v = floor(v);
    return encodeInt(int(v));
}

void main() {
    if (marker == 1.0) { //是指定的相机纹理
        vec2 pixel = floor(gl_FragCoord.xy); //FragCoord是屏幕上定位的坐标
        if (pixel.y >= 1.0 || pixel.x >= 41.0) { //只需要(0,0)到(40,0)的像素
            discard;
        }

        vec3 pos0 = position0.xyz / position0.w; //左下 这个w是用来取消插值的，还原了顶点坐标
        vec3 pos1 = position1.xyz / position1.w; //右下
        vec3 pos2 = position2.xyz / position2.w; //右上
        vec3 pos3 = position3.xyz / position3.w; //左上
        vec3 pos = pos0 * 0.5 + pos2 * 0.5; //中心位置（因为是对角平均）

        //PrimitiveID:
        vec3 pPos = gl_PrimitiveID % 2 == 0 ? pos1 : pos3; //一次PrimitiveID循环以游戏中被视为单元的被独立绘制的所有整体为单位
        //这里pPos找到了顶点对应三角形的“顶角”坐标，pos1和pos3（右下和左上）
        //Primitive ID=0对应了右下三角形，1则对应左上。
        //                                                        uses3  uses 1 
        vec3 tangent = normalize(gl_PrimitiveID % 2 == 1 ? pos0 - pPos : pPos - pos2);
        vec3 bitangent = normalize(gl_PrimitiveID % 2 == 0 ? pPos - pos0 : pos2 - pPos); 
        //                                                  uses 1              uses 3
        // Data
        // 0-15 - projection matrix
        // 16-31 - view matrix
        // 32-34 - position
        // 35-38 - tangent
        // 38-41 - bitangent
        if (pixel.x < 16) {
            mat4 mvp = ProjMat;
            int index = int(pixel.x);
            float value = mvp[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 32) {
            int index = int(pixel.x) - 16;
            float value = ModelViewMat[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 35) {
            fragColor = encodeFloat1024(pos[int(pixel.x) - 32]);
        } else if (pixel.x < 38) {
            fragColor = encodeFloat1024(tangent[int(pixel.x) - 35]);
        } else if (pixel.x < 41) {
            fragColor = encodeFloat1024(bitangent[int(pixel.x) - 38]);
        }
        return;
    }
    vec2 screensize = floor(ScreenSize);
    if (screen_marker == 1.0) { //是指定的相机纹理
        vec2 pixel = floor(gl_FragCoord.xy); //FragCoord是屏幕上定位的坐标
        if (pixel.y >= screensize.y*0.6+1|| pixel.x >= 41.0) { //只需要(0,0)到(40,0)的像素
            discard;
        }

        vec3 pos0 = position0a.xyz / position0a.w; //左下 这个w是用来取消插值的，还原了顶点坐标
        vec3 pos1 = position1a.xyz / position1a.w; //右下
        vec3 pos2 = position2a.xyz / position2a.w; //右上
        vec3 pos3 = position3a.xyz / position3a.w; //左上
        vec3 pos = pos0 * 0.5 + pos2 * 0.5; //中心位置（因为是对角平均）

        //PrimitiveID:
        vec3 pPos = gl_PrimitiveID % 2 == 0 ? pos1 : pos3; //一次PrimitiveID循环以游戏中被视为单元的被独立绘制的所有整体为单位
        //这里pPos找到了顶点对应三角形的“顶角”坐标，pos1和pos3（右下和左上）
        //Primitive ID=0对应了右下三角形，1则对应左上。
        //                                                        uses3  uses 1 
        vec3 tangent = normalize(gl_PrimitiveID % 2 == 1 ? pos0 - pPos : pPos - pos2);
        vec3 bitangent = normalize(gl_PrimitiveID % 2 == 0 ? pPos - pos0 : pos2 - pPos); 
        //                                                  uses 1              uses 3
        // Data
        // 0-15 - projection matrix
        // 16-31 - view matrix
        // 32-34 - position
        // 35-38 - tangent
        // 38-41 - bitangent
        if (pixel.x < 16) {
            mat4 mvp = ProjMat;
            int index = int(pixel.x);
            float value = mvp[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 32) {
            int index = int(pixel.x) - 16;
            float value = ModelViewMat[index / 4][index % 4];
            fragColor = encodeFloat(value);
        } else if (pixel.x < 35) {
            fragColor = encodeFloat1024(pos[int(pixel.x) - 32]);
        } else if (pixel.x < 38) {
            fragColor = encodeFloat1024(tangent[int(pixel.x) - 35]);
        } else if (pixel.x < 41) {
            fragColor = encodeFloat1024(bitangent[int(pixel.x) - 38]);
        }
        return;
    }

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator; //vanilla behaviour
    if (color.a < 0.1) {//vanilla behaviour
        discard;//vanilla behaviour
    }//vanilla behaviour

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);//vanilla behaviour
}
