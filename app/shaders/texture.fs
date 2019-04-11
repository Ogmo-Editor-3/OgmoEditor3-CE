precision mediump float;
uniform float alpha;
uniform sampler2D texture;
varying vec2 v_textcoord;

void main(void)
{
	gl_FragColor = texture2D(texture, v_textcoord) * vec4(1, 1, 1, alpha);
}