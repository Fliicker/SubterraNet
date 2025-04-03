#ifdef VERTEX_SHADER

precision highp float;
precision highp usampler2D;

out float vLevel;

uniform vec4 tileBox;
uniform vec2 sectorRange;       // 扇区范围, 表示最小细分单元尺寸 - ...
uniform vec2 dimensions;        // 512

uniform sampler2D boxTexture;
uniform usampler2D levelTexture;

vec4[] vertices = vec4[4](
    vec4(-1.0, 0.0, 0.0, 0.0),
    vec4(0.0, 0.0, 1.0, 0.0),
    vec4(-1.0, 1.0, 0.0, 1.0),
    vec4(0.0, 1.0, 1.0, 1.0)
);

void main() {

    ivec2 instanceCoords = ivec2(gl_InstanceID, 0);
    vec4 nodeData = texelFetch(boxTexture, instanceCoords, 0);
    float nodeStartX = floor((nodeData.r - tileBox[0]) / sectorRange.x);        // 得到扇区索引(位于第几个扇区)
    float nodeStartY = floor((nodeData.g - tileBox[1]) / sectorRange.y);
    float nodeEndX = ceil((nodeData.b - tileBox[0]) / sectorRange.x);
    float nodeEndY = ceil((nodeData.a - tileBox[1]) / sectorRange.y);

    vec2 vertices[4] = vec2[4](
        vec2(nodeStartX, nodeStartY),
        vec2(nodeEndX, nodeStartY),
        vec2(nodeStartX, nodeEndY),
        vec2(nodeEndX, nodeEndY)
    );

    vec2 vertex = vertices[gl_VertexID] / dimensions;       // 归一化到[0,1]空间 (可视区域只会占据512 * 512像素空间的一小部分)
    // vec2 vertex = vertices[gl_VertexID].xy;

    gl_Position = vec4(vertex * 2.0 - 1.0, 0.0, 1.0);
    // gl_Position = vec4(vertex, 0.0, 1.0);
    vLevel = float(texelFetch(levelTexture, instanceCoords, 0).r);
    // texcoords = vertices[gl_VertexID].zw;
}

#endif

#ifdef FRAGMENT_SHADER

precision highp float;

in float vLevel;

out uvec4 fragColor;

void main() {

    fragColor = uvec4(uint(vLevel), 0, 0, 0);
}

#endif