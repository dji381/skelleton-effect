import { OrbitControls } from "@react-three/drei";
import { EffectComposer, Bloom } from "@react-three/postprocessing";
import HalloweenAttack from "./HalloweenAttack";

const Experience = () => {
  return (
    <>
    <ambientLight intensity={1.5}/>
      <OrbitControls />
      <HalloweenAttack/>
      <EffectComposer>
        <Bloom
          intensity={1.5} 
          luminanceThreshold={0.2} 
          luminanceSmoothing={0.9} 
        />
      </EffectComposer>
    </>
  );
};

export default Experience;