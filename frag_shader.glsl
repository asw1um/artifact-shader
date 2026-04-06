uniform sampler2D tDiffuse;
uniform vec2 u_resolution;
#define pi 3.14159265359

varying vec2 vUv;
void main()
{
  // vec2 grid = fract( vUv * (u_resolution / 8.0));
  // NEW UV's for 8x8 Blocks
  vec2 block_size = 8.0 / u_resolution;
  vec2 block_uv = block_size * floor(vUv / block_size);

  vec2 real_pixel_size = 1.0 / u_resolution;

  vec3 luma_weights = vec3(0.299, 0.587, 0.114);

  for (float x = 0.0; x < 8.0; ++x)
  {
    for (float y = 0.0; y < 8.0; ++y)
    {
      vec2 target_uv = block_uv + (vec2(x,y) + 0.5) * real_pixel_size;
      vec4 pixel_colour = texture(tDiffuse, target_uv);
      float luminance = dot(pixel_colour.rgb, luma_weights) - 0.5;

      float cos_x = cos(((2x+1) * pi * target_uv.x) / 16);
      float cos_y = cos(((2y+1) * pi * target_uv.y) / 16);
    }
  }

  vec4 diffuse = texture2D(tDiffuse, block_uv);
  gl_FragColor = diffuse;
}