# artifact-shader

# TODO
-   [x] Vectorize certain operations in fragment shader
-   [x] Rename shaders for FDCT and IDCT respectively
-   [x] Alter resize function
-   [ ] Find optimal compression factor
-   [ ] Implement downsampled image for DCT then upscale to fit screen
-   [ ] Switch from Rec.709 to Rec.601 colour encoding standard
-   [x] Investigate fastest solution for storing quantization matrix
-   [ ] Separate DCT and IDCT into horizontal and vertical components to cut computation time
-   [ ] Consider using Taylor Series approximations for sin and cos to maybe speed up computation
-   [ ] Fix Improper Rendering on MacOS perhaps due to pixelRatio errors in main.js
