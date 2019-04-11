attribute vec2 a_position;
attribute vec4 a_color;	

uniform mat3 matrix;
uniform mat4 orthoMatrix;
uniform float alpha;

varying lowp vec4 v_color;

void main(void)
{
	gl_Position = orthoMatrix * vec4(matrix * vec3(a_position, 1.0), 1.0);
	v_color = vec4(a_color.rgb, a_color.a * alpha);
}