import * as THREE from "https://cdn.jsdelivr.net/npm/three@0.118/build/three.module.js";
import { OrbitControls } from "https://cdn.jsdelivr.net/npm/three@0.118/examples/jsm/controls/OrbitControls.js";
import { EffectComposer } from "https://cdn.jsdelivr.net/npm/three@0.122/examples/jsm/postprocessing/EffectComposer.js";
import { RenderPass } from "https://cdn.jsdelivr.net/npm/three@0.122/examples/jsm/postprocessing/RenderPass.js";
import { ShaderPass } from "https://cdn.jsdelivr.net/npm/three@0.122/examples/jsm/postprocessing/ShaderPass.js";

/**
 * Create Loaders
*/
const file_loader = new THREE.FileLoader();
const cube_texture_loader = new THREE.CubeTextureLoader();

/**
 * Setup JPEG Pass (ShaderPass)
*/
const vert_shader = await file_loader.loadAsync( './vert_shader.glsl' );
const frag_shader = await file_loader.loadAsync( './frag_shader.glsl' );

const jpeg_shader = 
{
  uniforms: 
  {
    tDiffuse: { value: null },
    u_resolution : {value : new THREE.Vector2(window.innerWidth, window.innerHeight)}
  },
  vertexShader: vert_shader,
  fragmentShader: frag_shader,
};

console.log(frag_shader);

const jpeg_pass = new ShaderPass(jpeg_shader);

// Canvas
const canvas = document.querySelector('canvas.webgl');

// Scene
const scene = new THREE.Scene();
const environment_map = cube_texture_loader.load([
      "./resources/posx.jpg",
      "./resources/negx.jpg",
      "./resources/posy.jpg",
      "./resources/negy.jpg",
      "./resources/posz.jpg",
      "./resources/negz.jpg",
]);
scene.background = environment_map;
scene.environment = environment_map;

// Renderer
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: false
});
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFShadowMap;
renderer.toneMapping = THREE.ReinhardToneMapping;
renderer.toneMappingExposure = 1.5;
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

// Camera
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 1000);
// const camera = new THREE.OrthographicCamera();
camera.position.z = 400;
// camera.zoom = 0.002122426378698158;
// camera.far = 5000;
scene.add(camera);

// Controls
const controls = new OrbitControls(camera, canvas);
controls.enableDamping = true;

// Composer
const render_target_parameters = {
    minFilter: THREE.NearestFilter,
    magFilter: THREE.NearestFilter,
    format: THREE.RGBAFormat,
    type: THREE.FloatType
};
// 2. Create the custom Render Target
const custom_render_target = new THREE.WebGLRenderTarget(
    window.innerWidth, 
    window.innerHeight, 
    render_target_parameters
);
const composer = new EffectComposer(renderer, custom_render_target);
composer.addPass(new RenderPass(scene, camera));
composer.addPass(jpeg_pass);
jpeg_pass.enabled = true;

/**
 * Lights
 */
const directionalLight = new THREE.DirectionalLight('#ffffff', 3)
directionalLight.castShadow = true
directionalLight.shadow.mapSize.set(1024, 1024)
directionalLight.shadow.camera.far = 15
directionalLight.shadow.normalBias = 0.05
directionalLight.position.set(0.25, 3, - 2.25)
scene.add(directionalLight)

// Objects
let object = new THREE.Object3D();
scene.add( object );

const geometry = new THREE.SphereGeometry( 1, 4, 4 );
const material = new THREE.MeshPhongMaterial( { color: 0xffffff, flatShading: true } );

for ( let i = 0; i < 100; i ++ ) 
{
  const mesh = new THREE.Mesh( geometry, material );
  mesh.position.set( Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5 ).normalize();
  mesh.position.multiplyScalar( Math.random() * 400 );
  mesh.rotation.set( Math.random() * 2, Math.random() * 2, Math.random() * 2 );
  mesh.scale.x = mesh.scale.y = mesh.scale.z = Math.random() * 50;
  object.add( mesh );
}

// Handle Resize
window.addEventListener('resize', () =>
{
    // Update camera
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    // Update renderer
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Update Composer
    composer.setSize(window.innerWidth, window.innerHeight);
    composer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
});

// Animate
const clock = new THREE.Clock();

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime();

    // Update controls
    controls.update();

    // Render
    composer.render(scene, camera);

    // Call tick again on the next frame
    window.requestAnimationFrame(tick);
}

tick();