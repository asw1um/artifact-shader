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
const float quant_matrix[64] = float[64](
                3.0,  5.0,  7.0,  9.0, 11.0, 13.0, 15.0, 17.0,
                5.0,  7.0,  9.0, 11.0, 13.0, 15.0, 17.0, 19.0,
                7.0,  9.0, 11.0, 13.0, 15.0, 17.0, 19.0, 21.0,
                9.0, 11.0, 13.0, 15.0, 17.0, 19.0, 21.0, 23.0,
                11.0, 13.0, 15.0, 17.0, 19.0, 21.0, 23.0, 25.0,
                13.0, 15.0, 17.0, 19.0, 21.0, 23.0, 25.0, 27.0,
                15.0, 17.0, 19.0, 21.0, 23.0, 25.0, 27.0, 29.0,
                17.0, 19.0, 21.0, 23.0, 25.0, 27.0, 29.0, 31.0
                );

void main()
{
        vec2 pixel_coord = floor(gl_FragCoord.xy);
        vec2 block_base_pixel = floor(pixel_coord / 8.0) * 8.0;
        vec2 local_uv = pixel_coord - block_base_pixel;

        vec3 sums = vec3(0.0);
        vec3 YCbCr = vec3(0.0);
        for (float x = 0.0; x < 8.0; ++x)
        {
                for (float y = 0.0; y < 8.0; ++y)
                {
                        vec2 target_pixel = block_base_pixel + vec2(x, y);
                        vec2 target_uv = (target_pixel + 0.5) / u_resolution;
                        vec4 pixel_colour = texture(tDiffuse, target_uv);

                        YCbCr.x = dot(pixel_colour.rgb, luma_weights) - 0.5;
                        YCbCr.y = dot(pixel_colour.rgb, Cb_weights);
                        YCbCr.z = dot(pixel_colour.rgb, Cr_weights);

                        float cos_x = cos((((2.0*x)+1.0) * pi * local_uv.x) / 16.0);
                        float cos_y = cos((((2.0*y)+1.0) * pi * local_uv.y) / 16.0);

                        sums += YCbCr * (cos_x * cos_y);
                }
        }
        vec2 C = vec2( ((local_uv.x == 0.0) ? 0.7071 : 1.0) , ((local_uv.y == 0.0) ? 0.7071 : 1.0) );
        vec3 DCT = (sums *= (0.25 * C.x * C.y));

        // Qunatize
        int index = (int(local_uv.y) * 8) + int(local_uv.x);
        float q_value = ( 20.0 * quant_matrix[index]) / 255.0;

        vec3 quantized_channels = vec3(round(DCT.x / q_value) , round(DCT.y / q_value), round(DCT.z / q_value)); 

        gl_FragColor = vec4(quantized_channels, 1.0);
}
