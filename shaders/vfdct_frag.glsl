uniform sampler2D tDiffuse;
uniform vec2 u_resolution;

varying vec2 vUv;

// Constants
const float pi = 3.14159265359;
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
        for (float y = 0.0; y < 8.0; ++y)
        {
                float target_pixel = block_base_pixel.y + y;
                vec2 target_uv = vec2((block_base_pixel.x + local_uv.x + 0.5) / u_resolution.x, (target_pixel + 0.5) / u_resolution.y);
                vec4 pixel_colour = texture(tDiffuse, target_uv);

                float cos_y = cos((((2.0*y)+1.0) * pi * local_uv.y) / 16.0);
                sums += (pixel_colour.xyz) * cos_y;

        }
        float Cy = (local_uv.y == 0.0) ? 0.7071 : 1.0;
        vec3 DCT = 0.5 * Cy * sums;

        float q_value = (10.0 * get_quant(int(local_uv.x), int(local_uv.y))) / 255.0;
        vec3 quantized_channels = vec3(round(DCT.x / q_value), round(DCT.y / q_value), round(DCT.z / q_value));

        gl_FragColor = vec4(quantized_channels, 1.0);
}
