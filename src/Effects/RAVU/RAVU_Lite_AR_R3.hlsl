// This file is generated by the scripts available at https://github.com/hauuau/magpie-prescalers
// Please don't edit this file directly.
// Generated by: ravu-lite.py --weights-file weights\ravu-lite_weights-r3.py --float-format float16dx --use-compute-shader --anti-ringing 0.8 --use-magpie --overwrite
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

//!MAGPIE EFFECT
//!VERSION 4

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam_INPUT;

//!TEXTURE
//!WIDTH  INPUT_WIDTH * 2
//!HEIGHT INPUT_HEIGHT * 2
Texture2D OUTPUT;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam_INPUT_LINEAR;

//!TEXTURE
//!SOURCE ravu_lite_lut3_f16.dds
//!FORMAT R16G16B16A16_FLOAT
Texture2D ravu_lite_lut3;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam_ravu_lite_lut3;

//!COMMON
#include "prescalers.hlsli"

#define LAST_PASS 1

//!PASS 1
//!DESC RAVU-Lite-AR (r3, compute)
//!IN INPUT, ravu_lite_lut3
//!OUT OUTPUT
//!BLOCK_SIZE 64, 16
//!NUM_THREADS 32, 8
shared float inp[432];

#define CURRENT_PASS 1

#define GET_SAMPLE(x) dot(x.rgb, rgb2y)
#define imageStore(out_image, pos, val) imageStoreOverride(pos, val.x)
void imageStoreOverride(uint2 pos, float value) {
	float2 UV = mul(rgb2uv, INPUT.SampleLevel(sam_INPUT_LINEAR, HOOKED_map(pos), 0).rgb);
	OUTPUT[pos] = float4(mul(yuv2rgb, float3(value.x, UV)), 1.0);
}

#define INPUT_tex(pos) GET_SAMPLE(vec4(texture(INPUT, pos)))
static const float2 INPUT_size = float2(GetInputSize());
static const float2 INPUT_pt = float2(GetInputPt());

#define ravu_lite_lut3_tex(pos) (vec4(texture(ravu_lite_lut3, pos)))

#define HOOKED_tex(pos) INPUT_tex(pos)
#define HOOKED_size INPUT_size
#define HOOKED_pt INPUT_pt

void Pass1(uint2 blockStart, uint3 threadId) {
	ivec2 group_base = ivec2(gl_WorkGroupID) * ivec2(gl_WorkGroupSize);
	int local_pos = int(gl_LocalInvocationID.x) * 12 + int(gl_LocalInvocationID.y);
#pragma warning(disable : 3557)
	for (int id = int(gl_LocalInvocationIndex); id < 432; id += int(gl_WorkGroupSize.x * gl_WorkGroupSize.y)) {
		uint x = (uint)id / 12, y = (uint)id % 12;
		inp[id] = HOOKED_tex(HOOKED_pt * vec2(float(group_base.x + x) + (-1.5), float(group_base.y + y) + (-1.5))).x;
	}
	barrier();
#if CURRENT_PASS == LAST_PASS
	uint2 destPos = blockStart + threadId.xy * 2;
	uint2 outputSize = GetOutputSize();
	if (destPos.x >= outputSize.x || destPos.y >= outputSize.y) {
		return;
	}
#endif
	vec3 abd = vec3(0.0, 0.0, 0.0);
	float gx, gy;
	gx = (inp[local_pos + 25] - inp[local_pos + 1]) / 2.0;
	gy = (inp[local_pos + 14] - inp[local_pos + 12]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
	gx = (inp[local_pos + 26] - inp[local_pos + 2]) / 2.0;
	gy = (inp[local_pos + 15] - inp[local_pos + 13]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
	gx = (inp[local_pos + 27] - inp[local_pos + 3]) / 2.0;
	gy = (inp[local_pos + 16] - inp[local_pos + 14]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
	gx = (inp[local_pos + 37] - inp[local_pos + 13]) / 2.0;
	gy = (inp[local_pos + 26] - inp[local_pos + 24]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
	gx = (inp[local_pos + 38] - inp[local_pos + 14]) / 2.0;
	gy = (inp[local_pos + 27] - inp[local_pos + 25]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.13080118386382833;
	gx = (inp[local_pos + 39] - inp[local_pos + 15]) / 2.0;
	gy = (inp[local_pos + 28] - inp[local_pos + 26]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
	gx = (inp[local_pos + 49] - inp[local_pos + 25]) / 2.0;
	gy = (inp[local_pos + 38] - inp[local_pos + 36]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
	gx = (inp[local_pos + 50] - inp[local_pos + 26]) / 2.0;
	gy = (inp[local_pos + 39] - inp[local_pos + 37]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
	gx = (inp[local_pos + 51] - inp[local_pos + 27]) / 2.0;
	gy = (inp[local_pos + 40] - inp[local_pos + 38]) / 2.0;
	abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
	float a = abd.x, b = abd.y, d = abd.z;
	float T = a + d, D = a * d - b * b;
	float delta = sqrt(max(T * T / 4.0 - D, 0.0));
	float L1 = T / 2.0 + delta, L2 = T / 2.0 - delta;
	float sqrtL1 = sqrt(L1), sqrtL2 = sqrt(L2);
	float theta = mix(mod(atan(L1 - a, b) + 3.141592653589793, 3.141592653589793), 0.0, abs(b) < 1.192092896e-7);
	float lambda = sqrtL1;
	float mu = mix((sqrtL1 - sqrtL2) / (sqrtL1 + sqrtL2), 0.0, sqrtL1 + sqrtL2 < 1.192092896e-7);
	float angle = floor(theta * 24.0 / 3.141592653589793);
	float strength = mix(mix(0.0, 1.0, lambda >= 0.004), mix(2.0, 3.0, lambda >= 0.05), lambda >= 0.016);
	float coherence = mix(mix(0.0, 1.0, mu >= 0.25), 2.0, mu >= 0.5);
	float coord_y = ((angle * 4.0 + strength) * 3.0 + coherence + 0.5) / 288.0;
	vec4 res = vec4(0.0, 0.0, 0.0, 0.0), w;
	vec4 lo = vec4(0.0, 0.0, 0.0, 0.0), hi = vec4(0.0, 0.0, 0.0, 0.0), lo2 = vec4(0.0, 0.0, 0.0, 0.0),
		 hi2 = vec4(0.0, 0.0, 0.0, 0.0), wg, cg4, cg4_1;
	w = texture(ravu_lite_lut3, vec2(0.038461538461538464, coord_y));
	res += inp[local_pos + 0] * w + inp[local_pos + 52] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.11538461538461539, coord_y));
	res += inp[local_pos + 1] * w + inp[local_pos + 51] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.19230769230769232, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 2] * w + inp[local_pos + 50] * w.wzyx;
	cg4 =
		vec4(0.1 + inp[local_pos + 2], 1.1 - inp[local_pos + 2], 0.1 + inp[local_pos + 50], 1.1 - inp[local_pos + 50]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.2692307692307692, coord_y));
	res += inp[local_pos + 3] * w + inp[local_pos + 49] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.34615384615384615, coord_y));
	res += inp[local_pos + 4] * w + inp[local_pos + 48] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.4230769230769231, coord_y));
	res += inp[local_pos + 12] * w + inp[local_pos + 40] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.5, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 13] * w + inp[local_pos + 39] * w.wzyx;
	cg4 = vec4(0.1 + inp[local_pos + 13], 1.1 - inp[local_pos + 13], 0.1 + inp[local_pos + 39],
			   1.1 - inp[local_pos + 39]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.5769230769230769, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 14] * w + inp[local_pos + 38] * w.wzyx;
	cg4 = vec4(0.1 + inp[local_pos + 14], 1.1 - inp[local_pos + 14], 0.1 + inp[local_pos + 38],
			   1.1 - inp[local_pos + 38]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.6538461538461539, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 15] * w + inp[local_pos + 37] * w.wzyx;
	cg4 = vec4(0.1 + inp[local_pos + 15], 1.1 - inp[local_pos + 15], 0.1 + inp[local_pos + 37],
			   1.1 - inp[local_pos + 37]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.7307692307692307, coord_y));
	res += inp[local_pos + 16] * w + inp[local_pos + 36] * w.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.8076923076923077, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 24] * w + inp[local_pos + 28] * w.wzyx;
	cg4 = vec4(0.1 + inp[local_pos + 24], 1.1 - inp[local_pos + 24], 0.1 + inp[local_pos + 28],
			   1.1 - inp[local_pos + 28]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.8846153846153846, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 25] * w + inp[local_pos + 27] * w.wzyx;
	cg4 = vec4(0.1 + inp[local_pos + 25], 1.1 - inp[local_pos + 25], 0.1 + inp[local_pos + 27],
			   1.1 - inp[local_pos + 27]);
	cg4_1 = cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	cg4 *= cg4;
	hi += cg4.x * wg + cg4.z * wg.wzyx;
	lo += cg4.y * wg + cg4.w * wg.wzyx;
	cg4 *= cg4_1;
	hi2 += cg4.x * wg + cg4.z * wg.wzyx;
	lo2 += cg4.y * wg + cg4.w * wg.wzyx;
	w = texture(ravu_lite_lut3, vec2(0.9615384615384616, coord_y));
	wg = max(vec4(0.0, 0.0, 0.0, 0.0), w);
	res += inp[local_pos + 26] * w;
	vec2 cg2 = vec2(0.1 + inp[local_pos + 26], 1.1 - inp[local_pos + 26]);
	vec2 cg2_1 = cg2;
	cg2 *= cg2;
	cg2 *= cg2;
	cg2 *= cg2;
	cg2 *= cg2;
	cg2 *= cg2;
	hi += cg2.x * wg;
	lo += cg2.y * wg;
	cg2 *= cg2_1;
	hi2 += cg2.x * wg;
	lo2 += cg2.y * wg;
	lo = 1.1 - lo2 / lo;
	hi = hi2 / hi - 0.1;
	res = mix(res, clamp(res, lo, hi), 0.800000);
	imageStore(out_image, ivec2(gl_GlobalInvocationID) * 2 + ivec2(0, 0), vec4(res[0], 0.0, 0.0, 0.0));
	imageStore(out_image, ivec2(gl_GlobalInvocationID) * 2 + ivec2(0, 1), vec4(res[1], 0.0, 0.0, 0.0));
	imageStore(out_image, ivec2(gl_GlobalInvocationID) * 2 + ivec2(1, 0), vec4(res[2], 0.0, 0.0, 0.0));
	imageStore(out_image, ivec2(gl_GlobalInvocationID) * 2 + ivec2(1, 1), vec4(res[3], 0.0, 0.0, 0.0));
}
