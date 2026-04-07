uniform sampler2D tDiffuse;
uniform vec2 u_resolution;

varying vec2 vUv;

// Constants
const float pi = 3.14159265359;
const mat3 ycbcr_to_rgb = mat3(
                1.0, 1.0, 1.0,              // Y multiplier
                0.0, -0.1873, 1.8556,       // Cb multiplier
                1.5748, -0.4681, 0.0        // Cr multiplier
                );
const vec3 luma_weights = vec3(0.2126, 0.7152, 0.0722);
const vec3 Cb_weights   = vec3(-0.1146, -0.3854, 0.5000);
const vec3 Cr_weights   = vec3(0.5000, -0.4542, -0.0458);

float get_quant(int col, int row)
{
        return 3.0 + float(col + row) * 2.0;
}

void main()
{
        vec2 pixel_coord = floor(gl_FragCoord.xy);
        vec2 block_base_pixel = floor(pixel_coord / 8.0) * 8.0;
        vec2 local_uv = pixel_coord - block_base_pixel;

        vec3 sums = vec3(0.0);
        for (float u = 0.0; u < 8.0; ++u)
        {
                float target_pixel = block_base_pixel.x + u;
                vec2 target_uv = vec2((target_pixel + 0.5)/ u_resolution.x, (block_base_pixel.y + local_uv.y + 0.5) / u_resolution.y);

                vec4 pixel_colour = texture(tDiffuse, target_uv);
                vec3 quantized_pixel = pixel_colour.xyz;
                float q_value = (10.0 * get_quant(int(u), int(local_uv.y))) / 255.0;

                quantized_pixel *= q_value;
                float Cu = (u == 0.0) ? 0.7071 : 1.0;
                float cos_x = cos((((2.0*local_uv.x)+1.0) * pi * u) / 16.0);
                sums += (cos_x * Cu) * quantized_pixel;
        }

        vec3 fi = 0.5 * sums;
        // fi.x += 0.5;
        gl_FragColor = vec4(fi, 1.0);
}
