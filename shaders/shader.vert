#version 450

// INPUTS:
// The vertex position
layout(location=0) in vec4 vertex;
// The uv texture coordinate input
layout(location=1) in vec2 uv_in;
// The model matrix columns
layout(location=2) in vec4 model_matrix_0;
layout(location=3) in vec4 model_matrix_1;
layout(location=4) in vec4 model_matrix_2;
layout(location=5) in vec4 model_matrix_3;
// The frame id of the sprite it in a texture array (or atlas)
layout(location=6) in uint tex_id_in;

// OUTPUTS TO FRAGMENT SHADER
// The uv texture coordinate
layout(location=0) out vec2 uv_out;
// The frame id of the sprite it in a texture array (used for animated sprites)
layout(location=1) flat out uint tex_id_out;

// We pass both orthographic and perspective projections to the Unifo
layout(set = 0, binding = 0) uniform Uniforms {
    mat4 ortho;
    mat4 persp;
};

void main() {

    mat4 model = mat4(
        model_matrix_0,
        model_matrix_1,
        model_matrix_2,
        model_matrix_3
    );

    // Pass the uv texture coordinate and animation frame id through unchanged
    uv_out = uv_in;
    tex_id_out = tex_id_out;

    // 1. We assume our sprites centres are always at (0.0, 0.0, 0.0)
    vec4 centre = vec4(vec3(0.0), 1.0);

    // 2. Calculate p_c, the perspective projection of the sprite quad centre
    vec4 p_c = persp * model * centre;

    // 3. Calculate o_c, the orthographic projection of the sprite quad centre
    vec4 o_c = ortho * model * centre;

    // 4. Calculate o_pos, the orthographic projection of the vertex
    vec4 o_pos = ortho * model * vertex;

    // 5. Convert p_c, o_c and o_pos to normalised device coordinates
    vec4 o_c_ndc = o_c/o_c.w;
    vec4 p_c_ndc =  p_c/p_c.w;
    vec4 o_pos_ndc = o_pos/o_pos.w;

    // 6. Calculate d_ndc, the distance between the perspective and orthographic centres in ndc coordinates
    vec4 d_ndc = p_c_ndc - o_c_ndc;

    // 7. Calculate the final ndc position, pos_dnc by shift o_pos_ndc by d_ndc
    // This is the key step were we shift our the orthoghraphic projection of our sprite centre to where
    // it would be located if it were rendered with a perspective projection
    vec4 pos_ndc = o_pos_ndc + d_ndc;

    // 8. Convert back to clip space for output to the rasteriser
    gl_Position = pos_ndc * o_pos.w;

}