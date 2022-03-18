shader_type canvas_item;

uniform float cur_char=0.0;
uniform int char_count=10;
void fragment() {
	
	if(1.0-abs(UV.y*float(char_count)-(cur_char+0.5))!=1.0&&COLOR.rgb!=vec3(0.,0.,0.)){COLOR.a=0.75-abs(UV.y*float(char_count)-(cur_char+0.5));};
	
}
