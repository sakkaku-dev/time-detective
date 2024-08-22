shader_type canvas_item;

uniform sampler2D noiseTexture;
uniform float dissolveAmount : hint_range(0, 1);
uniform float edgeSize = 0.1;
uniform vec4 edgeColor : source_color;
uniform float noiseTiling = 2;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform bool enable = true;
uniform bool inside = false;

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		//if (pattern == 0) {
			//offset = width - abs(x);
		//} else if (pattern == 1) {
			//offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		//} else if (pattern == 2) {
			//offset = width;
		//}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void fragment()
{
	vec4 originalTexture = texture(TEXTURE, UV);
	vec4 dissolveNoise = texture(noiseTexture, UV * noiseTiling);
	float remappedDissolve = dissolveAmount * (1.01  + edgeSize) - edgeSize;
	vec4 step1 = step(remappedDissolve, dissolveNoise);
	vec4 step2 = step(remappedDissolve + edgeSize, dissolveNoise);
	vec4 edge = step1 - step2;
	edge.a = originalTexture.a;
	vec4 edgeColorArea = edge * edgeColor;
	originalTexture.a *= step1.r;
	vec4 combinedColor = mix(originalTexture, edgeColorArea, edge.r);
	COLOR = combinedColor;

	if (enable) {
		if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(UV, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
			COLOR.a = (1.0 - COLOR.a) * color.a;
		}
	}

}

