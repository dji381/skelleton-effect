varying vec2 vUvs;
varying vec3 vNormals;
varying vec3 vPosition;
void main() {	
  vUvs = uv;
  vNormals = (modelMatrix * vec4(normal,0.0)).xyz;
  vPosition = (modelMatrix * vec4(position,1.0)).xyz;
}