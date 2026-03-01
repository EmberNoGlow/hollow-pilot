shader_type canvas_item;

uniform float uv_size = 1.0;
uniform float base_speed = 0.1;

uniform vec4 modulate0 : source_color;
uniform vec4 modulate1 : source_color;

float hash(float n) {
    return fract(n * 0.0243902439); // 1/41
}

float irandom(int i) {
    float f = float(i);
    return hash(f * 12.9898 + f * 78.233);
}

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, s), vec2(-s, c));
	return m * v;
}


void fragment() {
	vec4 col;
	vec4 mask;
	for (int i; i<10; i++){
		float size = float(i)*0.3;
		float rando = i>1 ? irandom(i)*0.3 : 0.0;
		vec2 rotated_uv = rotate(UV, rando);
	    vec2 uv = rotated_uv*uv_size*size;
		float speed = base_speed*float(i)*0.5;
	    float t = base_speed*TIME;
		uv.y += 0.03*sin(8.0*uv.x-t);
	    float f = 0.6+0.4*sin(5.0*(uv.x+uv.y+cos(3.0*uv.x+5.0*uv.y)+0.02*t)+sin(20.0*(uv.x+uv.y-0.1*t)));
	    vec4 col0 = vec4(0.9,0.95,1,1)*vec4(f);
		col += col0;
		if (i<=2){
			mask += col0;
		}
	}
	mask/=2.0;
	col/=10.0;
	mask = smoothstep(mask-0.1, mask-1.0, mask*0.4);
	COLOR = mix(mask*modulate0, col*modulate1, mask.a);
	COLOR.a = 1.0;
}
