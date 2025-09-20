uniform vec3 uPrimaryColor;
uniform vec3 uSecondaryColor;
uniform vec3 uSkullColor;
uniform float uFresnelPower;
uniform float uGlowPower;
uniform float uFresnelColorStep;
uniform float uTime;
uniform sampler2D uTexture;
varying vec3 vNormals;
varying vec3 vPosition;
varying vec2 vUvs;

float randomValue(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float interpolate(float a, float b, float t) {
    return mix(a, b, t); // mix() = (1-t)*a + t*b
}

float valueNoise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f); // easing

    vec2 c0 = i + vec2(0.0, 0.0);
    vec2 c1 = i + vec2(1.0, 0.0);
    vec2 c2 = i + vec2(0.0, 1.0);
    vec2 c3 = i + vec2(1.0, 1.0);

    float r0 = randomValue(c0);
    float r1 = randomValue(c1);
    float r2 = randomValue(c2);
    float r3 = randomValue(c3);

    float bottom = interpolate(r0, r1, f.x);
    float top = interpolate(r2, r3, f.x);
    return interpolate(bottom, top, f.y);
}

// --- SimpleNoise 2D avec UV et Scale ---
float simpleNoise(vec2 uv, float scale) {
    float t = 0.0;

    float freq = pow(2.0, 0.0);
    float amp = pow(0.5, 3.0 - 0.0);
    t += valueNoise(uv * scale / freq) * amp;

    freq = pow(2.0, 1.0);
    amp = pow(0.5, 3.0 - 1.0);
    t += valueNoise(uv * scale / freq) * amp;

    freq = pow(2.0, 2.0);
    amp = pow(0.5, 3.0 - 2.0);
    t += valueNoise(uv * scale / freq) * amp;

    return t;
}

float fresnel(float amount, vec3 normal, vec3 view) {
    return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), amount);
}

vec2 rotateUV(vec2 uv, float rotation) {
    float mid = 0.5;
    return vec2(
        cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
        cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
    );
}

void main() {
    vec3 viewDir = normalize(cameraPosition - vPosition);
    vec3 normals = normalize(vNormals);

    //Texure
    vec2 invertedUvs = vUvs.yx;
    float d = simpleNoise(invertedUvs + uTime * 0.1, 7.0);
    vec4 texel = texture2D(uTexture, fract(invertedUvs  + vec2(uTime * 0.1, -uTime * 0.1) + d));
    vec3 skullColor = texel.xyz * uSkullColor;
    skullColor *= 25.0;

    vec4 tex = texture2D(uTexture,invertedUvs * 2.0  + fract(vec2(-uTime * 0.1, -uTime * 0.1)  + d ));
    vec3 skullC = tex.xyz * uSecondaryColor;

    //Glowing Fresnel
    float fresnel = fresnel(uFresnelPower, viewDir, normals);
    vec3 glowColor = uPrimaryColor * fresnel;
    csm_Emissive = vec3(glowColor * uGlowPower);
    csm_DiffuseColor = vec4(skullColor, 1.0) + vec4(skullC,1.0);
    //csm_DiffuseColor = vec4(skullColor,1.0);
}
