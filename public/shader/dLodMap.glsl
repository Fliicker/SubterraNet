#ifdef VERTEX_SHADER

precision highp float;

out vec2 texcoords;

vec4[] vertices = vec4[4](
    vec4(-1.0, -1.0, 0.0, 0.0),
    vec4(1.0, -1.0, 1.0, 0.0),
    vec4(-1.0, 1.0, 0.0, 1.0),
    vec4(1.0, 1.0, 1.0, 1.0)
);

void main() {

    vec4 attributes = vertices[gl_VertexID];

    gl_Position = vec4(attributes.xy, 0.0, 1.0);
    texcoords = attributes.zw;
}

#endif

#ifdef FRAGMENT_SHADER

precision highp float;
precision highp usampler2D;

in vec2 texcoords;

uniform usampler2D lodMap;

out uvec4 fragColor;

vec2 uvCorrection(vec2 uv, vec2 dim) {
    return clamp(uv, vec2(0.0), dim - vec2(1.0));
}

int uSampling(usampler2D texture, vec2 uv, vec2 dim) {
    ivec2 realUV = ivec2(uvCorrection(uv, dim));
    return int(texelFetch(texture, realUV, 0).r);
}

void main() {

    vec2 lodDim = vec2(textureSize(lodMap, 0)); // 512
    vec2 uv = texcoords * lodDim;     // 恢复到纹理尺度

    // 求出当前及四个相邻像素层级
    int levelM = uSampling(lodMap, uv, lodDim);
    int levelN = uSampling(lodMap, uv + vec2(0.0, -1.0), lodDim);
    int levelE = uSampling(lodMap, uv + vec2(1.0, 0.0), lodDim);
    int levelS = uSampling(lodMap, uv + vec2(0.0, 1.0), lodDim);
    int levelW = uSampling(lodMap, uv + vec2(-1.0, 0.0), lodDim);

    uint dNM = uint(levelN != 0 ? clamp(levelM - levelN, 0, 2) : 0);
    uint dEM = uint(levelE != 0 ? clamp(levelM - levelE, 0, 2) : 0);
    uint dSM = uint(levelS != 0 ? clamp(levelM - levelS, 0, 2) : 0);
    uint dWM = uint(levelW != 0 ? clamp(levelM - levelW, 0, 2) : 0);

    // uint dNM = uint(max(levelM - levelN, 0));
    // uint dEM = uint(max(levelM - levelE, 0));
    // uint dSM = uint(max(levelM - levelS, 0));
    // uint dWM = uint(max(levelM - levelW, 0));

    uint color = (dNM << 24) + (dEM << 16) + (dSM << 8) + dWM;      // 四邻层级差异信息编码(限制在[0,2])

    fragColor = uvec4(color, 0, 0, 0);
}

#endif