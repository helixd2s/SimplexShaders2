#version 460 compatibility
//can be anything up to 450, 120 is still common due to compatibility reasons, but i suggest something from 130 upwards so you can use the new "varying" syntax, i myself usually use "400 compatibility"

//set the main framebuffer attachment to use RGB16 as the format to give us higher color precision, for hdr you would want to use RGB16F instead
//this is commented out since Optifine only needs to parse it without being used in code
/*
const int colortex0Format   = RGB16;
const int colortex2Format 	= RGBA16;
*/

//include math functions from file
#include "/lib/math.glsl"

//uniforms for scene texture binding
uniform sampler2D colortex0; 	//scene color
uniform sampler2D colortex1;	//scene normals
uniform sampler2D colortex2;	//scene lightmap
uniform sampler2D depthtex0;	//scene depth

//enable shadow2D shadows and bind shadowtex buffer
const bool shadowHardwareFiltering = true; 	//enable hardware filtering for shadow2D
uniform sampler2DShadow shadowtex1; 	//shadowdepth

//shadowmap resolution
const int shadowMapResolution   = 4096;

//shadowdistance
const float shadowDistance      = 128.0;

//input from vertex
layout (location = 0) in vec2 texcoord;
layout (location = 1) in vec3 lightVec;
layout (location = 2) in vec3 sunlightColor;
layout (location = 3) in vec3 skylightColor;
layout (location = 4) in vec3 torchlightColor;

uniform vec3 cameraPosition;

//uniforms (projection matrices)
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;

//
uniform vec3 skyColor;

//include position transform files
#include "/lib/transforms.glsl"
#include "/lib/shadowmap.glsl"

/* 	
	functions to be called in main and global variables go here
	however keep the amount of global variables rather low since the number of temp registers is limited,
	so large amounts of constantly changed global variables can cause performance bottlenecks
	also having non-constant global variables is considered bad practice and will cause issues
	if you sample a texture outside of void main() or a function
*/

//function to calculate position in shadowspace
vec3 getShadowCoordinate(in vec3 screenpos, in float bias) {
	vec3 position 	= screenpos;
		position   += vec3(bias)*lightVec;		//apply shadow bias to prevent shadow acne
		position 	= viewMAD(gbufferModelViewInverse, position); 	//do shadow position tranforms
		position 	= viewMAD(shadowModelView, position);
		position 	= projMAD(shadowProjection, position);

	//apply far plane fix and shadowmap distortion
		position.z *= 0.2;
		warpShadowmap(position.xy);

	return position*0.5+0.5;
}

//calculate shadow, using shadow2D shadows because they are a lot easier to setup here
float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	float shadow 	= shadow2D(shadowtex, shadowpos).x;

	return shadow;
}

//simple lambertian diffuse shading, google "diffuse shading" for a better explaination than i could give right now
float getDiffuse(vec3 normal, vec3 lightvec) {
	float lambert 	= dot(normal, lightvec);
		lambert 	= max(lambert, 0.0);
	return lambert;
}

//void main is basically the main part where stuff get's done and function get called
void main() {
	//sample necessary scene textures
	vec3 sceneColor 	= texture(colortex0, texcoord, 0).rgb;
	vec3 sceneDepth 	= texture(depthtex0, texcoord, 0).xxx;
	vec3 sceneNormal	= normalize(texture(colortex1, texcoord, 0).xyz*2.0-1.0); 	//get the normals from the buffer we wrote them to
	vec2 sceneLightmap 	= texture(colortex2, texcoord, 0).xy; 	//Get the lightmap from the buffer we previously wrote it to in gbuffers
		sceneLightmap.x = pow2(sceneLightmap.x); 	//this improves the torchlight falloff a bit

	//calculate necessary positions
	vec3 screenpos 	= getScreenpos(sceneDepth.x, texcoord);

	//make terrain mask
	bool isTerrain 	= sceneDepth.x < 1.0f;

	//variables for shadow calculation
	float shadow 		= 1.0;
	float comparedepth 	= 0.0;

	//check if it even is terrain and then do shading
	/*if (isTerrain) {
		float diffuse 		= getDiffuse(sceneNormal, lightVec); 	//get diffuse shading

		if (diffuse>0.0) {
			vec3 shadowcoord 	= getShadowCoordinate(screenpos, 0.06); 	//get shadow coordinate
				shadow 			= getShadow(shadowtex1, shadowcoord); 		//get shadows
		}
		shadow 	= min(diffuse, shadow); 		//blend shadows and diffuse shading, this was is good since it helps to hide some of the shadow acne

		vec3 lightcolor 	= sunlightColor*shadow + skylightColor*sceneLightmap.y;	//apply sunlight and skylight color based on lighting
			lightcolor 	    = max(lightcolor, torchlightColor*sceneLightmap.x);

		sceneColor 		   *= clamp(lightcolor, 0.f.xxx, 1.f.xxx); 		//apply lighting to diffuse
	}*/

	if (texcoord.y > 0.5f) {
		sceneColor.rgb = mix(pow(skyColor.xyz, vec3(2.2f)), sceneColor.rgb, texture(colortex0, texcoord, 0).a);
	}
	 

	//write to framebuffer attachment
	/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(sceneColor, 1.0);
}
