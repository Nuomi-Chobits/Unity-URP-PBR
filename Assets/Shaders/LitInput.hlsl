#ifndef CUSTOM_LIT_INPUT_INCLUDED
#define CUSTOM_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _Metallic;
    half _Roughness;
    half _Normal;
    half _OcclusionStrength;
    half _Cutoff;
    half _EnvRotation;
CBUFFER_END

TEXTURE2D(_BaseMap);         SAMPLER(sampler_BaseMap);
TEXTURE2D(_MetallicMap);     SAMPLER(sampler_MetallicMap);
TEXTURE2D(_RoughnessMap);    SAMPLER(sampler_RoughnessMap);
TEXTURE2D(_NormalMap);       SAMPLER(sampler_NormalMap);
TEXTURE2D(_OcclusionMap);    SAMPLER(sampler_OcclusionMap);

#endif