import * as THREE from "three";
import CustomShaderMaterial from "three-custom-shader-material";
import vertexShader from "@/shaders/vertex.glsl";
import fragmentShader from "@/shaders/fragment.glsl";
import { useRef } from "react";
import { useControls } from "leva";
import { useTexture } from "@react-three/drei";
import { useFrame } from "@react-three/fiber";

const HalloweenAttack = () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const shaderRef = useRef<any>(null!);
  const texture = useTexture("texture/skull-texture.jpg");
  const vfxTexture = useTexture("texture/vfx2.png");
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.minFilter = THREE.NearestFilter
  vfxTexture.wrapS = THREE.RepeatWrapping;
  vfxTexture.wrapT = THREE.RepeatWrapping;
  vfxTexture.minFilter = THREE.NearestFilter
  const {
    uPrimaryColor,
    uSecondaryColor,
    uFresnelPower,
    uGlowPower,
    uFresnelColorStep,
    uSkullColor
  } = useControls({
    uPrimaryColor: "#5b2d90",
    uSecondaryColor: "#502f58",
    uSkullColor: '#180a2e',
    uFresnelPower: {
      value: 4.0,
      min: 1.0,
      max: 10,
      step: 1.0,
    },
    uFresnelColorStep: {
      value: 0.1,
      min: 0.0,
      max: 1.0,
      step: 0.1,
    },
    uGlowPower: {
      value: 11.0,
      min: 1.0,
      max: 30,
      step: 1.0,
    },
  });
  useFrame((state) => {
    if (shaderRef.current?.uniforms) {
      shaderRef.current.uniforms.uTime.value = state.clock.elapsedTime;
    }
  });
  return (
    <mesh position={[0, 0, 0]}>
      <sphereGeometry args={[1, 50, 50]} />
      {/* <planeGeometry args={[1,1,50,50]}/> */}
      {/* <boxGeometry args={[1,1,1]}/> */}
      <CustomShaderMaterial<typeof THREE.MeshStandardMaterial>
        baseMaterial={THREE.MeshStandardMaterial}
        ref={shaderRef}
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        transparent={true}
        alphaTest={0.1}
        uniforms={{
          uPrimaryColor: { value: new THREE.Color(uPrimaryColor) },
          uSecondaryColor: { value: new THREE.Color(uSecondaryColor) },
          uSkullColor : {value: new THREE.Color(uSkullColor)},
          uFresnelPower: { value: uFresnelPower },
          uGlowPower: { value: uGlowPower },
          uFresnelColorStep: { value: uFresnelColorStep },
          uTexture: { value: texture },
          uVfxTexture: { value: vfxTexture },
          uTime:{value:0.0}

        }}
      />
    </mesh>
  );
};

export default HalloweenAttack;
