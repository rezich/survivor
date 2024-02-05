BASE_VIGNETTE_AMOUNT :: 0.15;

Full_Screen_Effect :: enum {
    VIGNETTE;
}

init_full_screen_effects :: () {
    shader_vignette.gl_handle = get_shader_program(SHADER_VIGNETTE);
}

render_full_screen_effects :: () {
    set_render_target_for_effect(.VIGNETTE);
    Simp.immediate_begin();

    set_shader_for_vignette();
    render_immediate_full_screen_quad();

    Simp.immediate_flush();
}

render_full_screen_effects_to_render_target :: () {
    Simp.set_shader_for_images(get_render_target_for_effect(.VIGNETTE));
    render_immediate_full_screen_quad();
}




#scope_file

get_render_target_for_effect :: (effect: Full_Screen_Effect) -> *Simp.Texture {
    return window.full_screen_render_targets[effect + 2];
}
set_render_target_for_effect :: (effect: Full_Screen_Effect) {
    Simp.set_render_target(get_render_target_for_effect(effect));
}

set_shader_for_vignette :: () {
    shader := *shader_vignette;
    Simp.immediate_set_shader(shader);
    Simp.set_projection();
    Simp.immediate_set_texture(window.full_screen_render_targets[Full_Screen_Render_Target.OUTPUT]);
    set_parameter(shader, "resolution", .{ xx window.width, xx window.height, 0});

    amount := BASE_VIGNETTE_AMOUNT;
    amount += ((state.camera.scale - 1) / Player.HIT_EFFECT_ZOOM) * Player.HIT_EFFECT_VIGNETTE_SCALE;
    //amount *= window.scale_from_720;

    set_parameter(shader, "amount", amount);
    set_parameter(shader, "time", state.time);
}

set_parameter :: (shader: *Simp.Shader, name: *u8, v: Vector3) {
    loc := glGetUniformLocation(shader.gl_handle, name);
    if loc < 0   log_error("Unknown parameter: '%'\n", to_string(name));
    if loc >= 0  glUniform3fv(loc, 1, *v.x);
}

set_parameter :: (shader: *Simp.Shader, name: *u8, f: float) {
    loc := glGetUniformLocation(shader.gl_handle, name);
    if loc < 0   log_error("Unknown parameter: '%'\n", to_string(name));
    if loc >= 0  glUniform1f(loc, f);
}

set_parameter :: (shader: *Simp.Shader, name: *u8, i: s32) {
    loc := glGetUniformLocation(shader.gl_handle, name);
    if loc < 0   log_error("Unknown parameter: '%'\n", to_string(name));
    if loc >= 0  glUniform1i(loc, i);
}

shader_vignette: Simp.Shader = .{alpha_blend = true};

SHADER_VIGNETTE :: #string END
OUT_IN vec2 TexCoords;
OUT_IN vec4 iterated_color;

#ifdef VERTEX_SHADER
in vec4 vert_position;
in vec4 vert_color;
in vec2 vert_uv0;

uniform mat4 projection;

void main() {
    TexCoords = vec2(vert_uv0.x, 1.0-vert_uv0.y);  // @Cleanup: Figure out what to do to avoid this vertical flip... sigh!
    gl_Position = projection * vec4(vert_position.xy, 0.0, 1.0);
    iterated_color = vert_color;
}
#endif // VERTEX_SHADER

#ifdef FRAGMENT_SHADER
out vec4 color;
uniform sampler2D diffuse_texture;

uniform float time;
uniform float amount;
uniform vec3 resolution;

float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }
float rand(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }
//float rand(vec3 co){ return rand(co.xy+rand(co.z)); }

void main () {
    vec4 color_tex = iterated_color * texture(diffuse_texture, TexCoords);

    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 coord = (uv-0.5) * (resolution.x/resolution.y)*2.0;
    float rf = sqrt(dot(coord, coord)) * amount * (0.75 + rand(uv * time) * 0.25);
    float rf2_1 = rf*rf + 1.0;
    float e = 1.0 / (rf2_1*rf2_1);

    color = vec4(color_tex.rgb * e, 1.0);
}
#endif // FRAGMENT_SHADER
END

get_shader_program :: (shader_text: string) -> GLuint {
    LOG_BUFFER_SIZE :: 512;

    make_shader_object :: (shader: string, prefix: string, shader_type : GLenum) -> GLuint {
        shader_object := glCreateShader(shader_type);

        //shader_str := temp_c_string(shader);
        shaders: [2] *u8;
        lengths: [2] s32;

        shaders[0] = prefix.data;
        shaders[1] = shader.data;
        lengths[0] = xx prefix.count;
        lengths[1] = xx shader.count;

        glShaderSource(shader_object, 2, shaders.data, lengths.data);

        glCompileShader(shader_object);

        success : GLint;
        glGetShaderiv(shader_object, GL_COMPILE_STATUS, *success);

        if !success then {
            log_data: [LOG_BUFFER_SIZE] u8;
            glGetShaderInfoLog(shader_object, log_data.count, null, log_data.data);
            log("%", to_string(log_data.data), flags=.ERROR);
            return 0;
        }

        return shader_object;
    }

    // @MODIFIED GLES has a different version directive and needs to specify float precision.
    #if OS == .ANDROID {
        PREFIX_V :: #string END
        #version 300 es
        #define VERTEX_SHADER
        #define OUT_IN out
        precision mediump float;
        END

        PREFIX_F :: #string END
        #version 300 es
        #define FRAGMENT_SHADER
        #define OUT_IN in
        precision mediump float;
        END
    } else {
        PREFIX_V :: #string END
        #version 330 core
        #define VERTEX_SHADER
        #define OUT_IN out
        END

        PREFIX_F :: #string END
        #version 330 core
        #define FRAGMENT_SHADER
        #define OUT_IN in
        END
    }

    shader_v := make_shader_object(shader_text, PREFIX_V, GL_VERTEX_SHADER);
    shader_f := make_shader_object(shader_text, PREFIX_F, GL_FRAGMENT_SHADER);
    shader_p := glCreateProgram();

    glAttachShader(shader_p, shader_v);
    glAttachShader(shader_p, shader_f);
    glLinkProgram(shader_p);

    success : GLint = 0;
    glGetProgramiv(shader_p, GL_LINK_STATUS, *success);

    if !success then {
        log_data: [LOG_BUFFER_SIZE] u8;
        glGetProgramInfoLog(shader_p, log_data.count, null, log_data.data);
        log_error("%", to_string(log_data.data));
        return 0;
    }

    glDeleteShader(shader_v);
    glDeleteShader(shader_f);

    return shader_p;
}

#import "GL";
