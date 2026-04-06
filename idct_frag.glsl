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
        for (float u = 0.0; u < 8.0; ++u)
        {
                for (float v = 0.0; v < 8.0; ++v)
                {
                        vec2 target_pixel = block_base_pixel + vec2(u, v);
                        vec2 target_uv = (target_pixel + 0.5) / u_resolution;
                        vec4 pixel_colour = texture(tDiffuse, target_uv);

                        vec3 quantized_pixel = vec3(texture(tDiffuse, target_uv).xyz);
                        // float q_Y = texture(tDiffuse, target_uv).x;
                        // float q_Cb = texture(tDiffuse, target_uv).y;
                        // float q_Cr = texture(tDiffuse, target_uv).z;
                        // vec3 q = vec3(q_Y, q_Cb, q_Cr);
                        int index = (int(v) * 8) + int(u);
                        float q_value = ( 20.0 * quant_matrix[index]) / 255.0;
                        
                        quantized_pixel *= q_value;
                        // float o_Y = q_Y * q_value; 
                        // float o_Cb = q_Cb * q_value; 
                        // float o_Cr = q_Cr * q_value; 
                        
                        vec2 C = vec2( ((u == 0.0) ? 0.7071 : 1.0), ((v == 0.0) ? 0.7071 : 1.0));
                        // float Cu = (u == 0.0) ? 0.7071 : 1.0;
                        // float Cv = (v == 0.0) ? 0.7071 : 1.0;

                        float cos_x = cos((((2.0*local_uv.x)+1.0) * pi * u) / 16.0);
                        float cos_y = cos((((2.0*local_uv.y)+1.0) * pi * v) / 16.0);
                        
                        sums += (cos_x * cos_y * C.x * C.y) * quantized_pixel;
                        // sum_Y += Cu * Cv * o_Y * cos_x * cos_y;
                        // sum_Cb += Cu * Cv * o_Cb * cos_x * cos_y;
                        // sum_Cr += Cu * Cv * o_Cr * cos_x * cos_y;
                }
        }
        
        vec3 fi = 0.25 * sums;
        fi.x += 0.5;
        // float fi_Y = (0.25 * sum_Y) + 0.5;
        // float fi_Cb = (0.25 * sum_Cb);
        // float fi_Cr = (0.25 * sum_Cr);

        // vec3 close = vec3(fi_Y, fi_Cb, fi_Cr);
        vec3 rgb_channels = ycbcr_to_rgb * fi;
        gl_FragColor = vec4(rgb_channels, 1.0);
}
