#version 330

in vec4 vertex;
in vec2 tex;

out vec2 out_uvs;

void main()
{
    gl_Position = vec4(vertex.xyz, 1.0);
    out_uvs = tex;
}
