uniform sampler2D tDiffuse;
uniform vec2 u_resolution;

varying vec2 vUv;

// Constants
const float pi = 3.14159265359;
const vec3 luma_weights = vec3(0.2126, 0.7152, 0.0722);
const vec3 Cb_weights   = vec3(-0.1146, -0.3854, 0.5000);
const vec3 Cr_weights   = vec3(0.5000, -0.4542, -0.0458);

vec3 rgb2YCbCr(vec3 rgb){
    float y = dot(rgb, vec3(0.299, 0.587, 0.114));
    float cb = .5 + dot(rgb, vec3(-0.168736, -0.331264, 0.5));
    float cr = .5 + dot(rgb, vec3(0.5, -0.418688, -0.081312));
    return vec3(y, cb, cr);
}

void main()
{
        vec2 pixel_coord = floor(gl_FragCoord.xy);
        vec2 block_base_pixel = floor(pixel_coord / 8.0) * 8.0;
        vec2 local_uv = pixel_coord - block_base_pixel;

        vec3 sums = vec3(0.0);
        vec3 YCbCr = vec3(0.0);
        for (float x = 0.0; x < 8.0; ++x)
        {
                float target_pixel = block_base_pixel.x + x;
                vec2 target_uv = vec2((target_pixel + 0.5) / u_resolution.x, (block_base_pixel.y + local_uv.y + 0.5) / u_resolution.y);
                vec4 pixel_colour = texture(tDiffuse, target_uv);

                YCbCr = rgb2YCbCr(pixel_colour.rgb);
                YCbCr.x + 0.5;
                //YCbCr.x = dot(pixel_colour.rgb, luma_weights) - 0.5;
                //YCbCr.y = dot(pixel_colour.rgb, Cb_weights);
                //YCbCr.z = dot(pixel_colour.rgb, Cr_weights);

                float cos_x = cos((((2.0*x)+1.0) * pi * local_uv.x) / 16.0);
                sums += (YCbCr * cos_x);
        }
        float Cx = (local_uv.x == 0.0) ? 0.7071 : 1.0;
        vec3 DCT = (sums *= (0.50 * Cx));
        gl_FragColor = vec4(DCT, 1.0);
}
