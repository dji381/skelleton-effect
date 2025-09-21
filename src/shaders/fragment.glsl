#include "../../lygia/generative/pnoise.glsl"

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
float inverseLerp(float v, float minValue, float maxValue) {
    return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

float fresnel(float amount, vec3 normal, vec3 view) {
    return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), amount);
}

void main() {
    vec3 viewDir = normalize(cameraPosition - vPosition);
    vec3 normals = normalize(vNormals);

    //Texure
    vec2 invertedUvs = vUvs.yx;
    float d = sin(uTime);
    float d2 = pnoise(vec3(invertedUvs * 2.0, uTime * 0.1), vec3(2.0, 2.0, 2.0)) * 0.5 + 0.5;
    //Glowing skull
    vec4 texel = texture2D(uTexture, fract(invertedUvs + vec2(uTime * 0.1 + d2, -uTime * 0.1 + d2)));
    vec3 skullColor = texel.xyz * uSkullColor;
    skullColor *= 25.0;
    //Dark skull
    vec4 tex = texture2D(uTexture, invertedUvs * 2.0 + fract(vec2(-uTime * 0.1 + d2 * 1.2 + d * 0.5, -uTime * 0.1 + d2 * 1.2)));
    vec3 skullC = tex.xyz * uSecondaryColor;

    //Glowing Fresnel
    float fresnel = fresnel(uFresnelPower, viewDir, normals);
    vec3 glowColor = uPrimaryColor * fresnel;
    csm_Emissive = vec3(glowColor * uGlowPower);
    csm_DiffuseColor = vec4(skullColor, 1.0) + vec4(skullC, 1.0);
}
