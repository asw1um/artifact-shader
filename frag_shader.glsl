uniform sampler2D tDiffuse;
uniform vec2 u_resolution;
float pi = 3.14159265359;
mat3 ycbcr_to_rgb = mat3(
    1.0, 1.0, 1.0,              // Y multiplier
    0.0, -0.1873, 1.8556,       // Cb multiplier
    1.5748, -0.4681, 0.0        // Cr multiplier
);
vec3 luma_weights = vec3(0.2126, 0.7152, 0.0722);
vec3 Cb_weights   = vec3(-0.1146, -0.3854, 0.5000);
vec3 Cr_weights   = vec3(0.5000, -0.4542, -0.0458);

varying vec2 vUv;
void main()
{
  // vec2 grid = fract( vUv * (u_resolution / 8.0));
  // NEW UV's for 8x8 Blocks
  vec2 block_size = 8.0 / u_resolution;
  vec2 block_uv = block_size * floor(vUv / block_size);

  vec2 real_pixel_size = 1.0 / u_resolution;
  vec2 local_uv = floor((vUv - block_uv) / real_pixel_size);

  // Sums
  float sum_Y = 0.0;
  float sum_Cb = 0.0;
  float sum_Cr = 0.0;
  for (float x = 0.0; x < 8.0; ++x)
  {
    for (float y = 0.0; y < 8.0; ++y)
    {
      vec2 target_uv = block_uv + (vec2(x,y) + 0.5) * real_pixel_size;
      vec4 pixel_colour = texture(tDiffuse, target_uv);

      float luminance = dot(pixel_colour.rgb, luma_weights) - 0.5;
      float Cb = dot(pixel_colour.rgb, Cb_weights);
      float Cr = dot(pixel_colour.rgb, Cr_weights);

      float cos_x = cos((((2.0*x)+1.0) * pi * local_uv.x) / 16.0);
      float cos_y = cos((((2.0*y)+1.0) * pi * local_uv.y) / 16.0);

      sum_Y += (luminance * cos_x * cos_y);
      sum_Cb += (Cb * cos_x * cos_y);
      sum_Cr += (Cr * cos_x * cos_y);
    }
  }
  
  float Cu = (local_uv.x == 0.0) ? 0.7071 : 1.0;
  float Cv = (local_uv.y == 0.0) ? 0.7071 : 1.0;

  float DCT_Y = (0.25 * sum_Y * Cu * Cv) + 0.5;
  float DCT_Cb = 0.25 * sum_Cb * Cu * Cv;
  float DCT_Cr = 0.25 * sum_Cr * Cu * Cv;

  vec3 YCbCr = vec3(DCT_Y, DCT_Cb, DCT_Cr);
  vec3 rgb = ycbcr_to_rgb * YCbCr;

  // vec4 diffuse = texture2D(tDiffuse, block_uv);
  gl_FragColor = vec4(rgb, 1.0);
}