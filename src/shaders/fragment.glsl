#include "../../lygia/generative/pnoise.glsl"

uniform vec3 uPrimaryColor;
uniform vec3 uSecondaryColor;
uniform vec3 uSkullColor;
uniform float uFresnelPower;
uniform float uGlowPower;
uniform float uFresnelColorStep;
uniform float uTime;
uniform sampler2D uTexture;
uniform sampler2D uVfxTexture;
varying vec3 vNormals;
varying vec3 vPosition;
varying vec2 vUvs;

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
    vec4 tex = texture2D(uTexture, invertedUvs + fract(vec2(-uTime * 0.2 + d2, -uTime * 0.3 + d2 * 1.8)));
    vec3 skullC = tex.xyz * uSecondaryColor;
    vec4 skullBlend = vec4(skullColor, 1.0) + vec4(skullC, 1.0);
    //Vfx Texture
    vec3 vfx = texture2D(uVfxTexture,fract((vUvs * 2.0) + vec2(uTime,0.0))).xyz;
    vec4 vfxColor = vec4(vec3(vfx * uSecondaryColor),vfx.r);
    //Glowing Fresnel
    float fresnel = fresnel(uFresnelPower, viewDir, normals);
    vec3 glowColor = uPrimaryColor * fresnel;
    csm_Emissive = vec3(glowColor * uGlowPower);
    csm_DiffuseColor = mix(skullBlend,vfxColor,smoothstep(0.0,uFresnelColorStep,fresnel));
}
