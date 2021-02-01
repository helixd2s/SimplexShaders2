#version 460 compatibility
#extension GL_NV_gpu_shader5 : enable

uniform sampler2DArray depthtex0;
uniform sampler2DArray colortex0;
uniform sampler2DArray colortex1;
uniform sampler2DArray colortex2;
uniform sampler2DArray colortex3;
uniform sampler2DArray colortex4;
uniform sampler2DArray colortex5;
uniform sampler2DArray colortex6;
uniform sampler2DArray colortex7;

layout (location = 0) in vec2 vtexcoord;
layout (location = 1) in flat int layerId;

#include "/lib/common.glsl"

/*DRAWBUFFERS:01234567*/

/*
    const int colortex0Format = RGBA32F;
    const int colortex1Format = RGBA32F;
    const int colortex2Format = RGBA32F;
    const int colortex3Format = RGBA32F;
    const int colortex4Format = RGBA32F;
    const int colortex5Format = RGBA32F;
    const int colortex6Format = RGBA32F;
    const int colortex7Format = RGBA32F;
    const int colortex8Format = RGBA32F;

    const vec4 colortex0ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex1ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex2ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex3ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex4ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex5ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex6ClearColor = vec4(0.f,0.f,0.f,0.f);
    const vec4 colortex7ClearColor = vec4(0.f,0.f,0.f,0.f);

    const bool colortex7Clear = false;
*/

// FLIP PROBLEM RESOLVE
// REQUIRED HACK PROGRAM

void main() {
    gl_FragData[0] = sampleLayer(colortex0, vtexcoord, layerId);
    gl_FragData[1] = sampleLayer(colortex1, vtexcoord, layerId);
    gl_FragData[2] = sampleLayer(colortex2, vtexcoord, layerId);
    gl_FragData[3] = sampleLayer(colortex3, vtexcoord, layerId);
    gl_FragData[4] = sampleLayer(colortex4, vtexcoord, layerId);
    gl_FragData[5] = sampleLayer(colortex5, vtexcoord, layerId);
    gl_FragData[6] = sampleLayer(colortex6, vtexcoord, layerId);
    gl_FragData[7] = sampleLayer(colortex7, vtexcoord, layerId);
}