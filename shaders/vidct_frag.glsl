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

vec3 YCbCr2rgb(vec3 ycbcr) {
    float cb = ycbcr.y - .5;
    float cr = ycbcr.z - .5;
    float y = ycbcr.x;
    float r = 1.402 * cr;
    float g = -.344 * cb - .714 * cr;
    float b = 1.772 * cb;
    return vec3(r, g, b) + y;
}

void main()
{
        vec2 pixel_coord = floor(gl_FragCoord.xy);
        vec2 block_base_pixel = floor(pixel_coord / 8.0) * 8.0;
        vec2 local_uv = pixel_coord - block_base_pixel;

        vec3 sums = vec3(0.0);
        for (float v = 0.0; v < 8.0; ++v)
        {
                float target_pixel = block_base_pixel.y + v;
                vec2 target_uv = vec2((block_base_pixel.x + local_uv.x + 0.5) / u_resolution.x, (target_pixel + 0.5) / u_resolution.y);
                vec4 pixel_colour = texture(tDiffuse, target_uv);

                float Cy = (v == 0.0) ? 0.7071 : 1.0;
                float cos_y = cos((((2.0*local_uv.y)+1.0) * pi * v) / 16.0);
                sums += (cos_y * Cy) * pixel_colour.xyz;

        }
        vec3 fi = 0.50 * sums;
        fi.x += 0.5;
        vec3 rgb_channels = ycbcr_to_rgb * fi;
        gl_FragColor = vec4(rgb_channels, 1.0);
}
