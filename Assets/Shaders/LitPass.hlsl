#ifndef CUSTOM_LIT_PASS_INCLUDED
#define CUSTOM_LIT_PASS_INCLUDED

#include "CustomLitData.hlsl"
#include "CustomLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float3 positionWS   : TEXCOORD1;
    float3 normalWS     : TEXCOORD2;
    half4  tangentWS    : TEXCOORD3;    // xyz: tangent, w: sign
    float4 shadowCoord  : TEXCOORD4;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

void InitializeCustomLitData(Varyings input,out CustomLitData customLitData)
{
    customLitData = (CustomLitData)0;

    customLitData.positionWS = input.positionWS;
    customLitData.V = GetWorldSpaceNormalizeViewDir(input.positionWS);
    customLitData.N = normalize(input.normalWS);
    customLitData.T = normalize(input.tangentWS.xyz);
    customLitData.B = normalize(cross(customLitData.N,customLitData.T) * input.tangentWS.w);    
    customLitData.ScreenUV = GetNormalizedScreenSpaceUV(input.positionCS);
}

void InitializeCustomSurfaceData(Varyings input,out CustomSurfacedata customSurfaceData)
{
    customSurfaceData = (CustomSurfacedata)0;
    
    half4 color = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv) * _BaseColor;
    
    //albedo & alpha & specular
    customSurfaceData.albedo = color.rgb;
    customSurfaceData.alpha  = color.a;
    #if defined(_ALPHATEST_ON)
        clip(customSurfaceData.alpha - _Cutoff);
    #endif
    customSurfaceData.specular = (half3)0;

    //metallic & roughness
    half metallic = SAMPLE_TEXTURE2D(_MetallicMap,sampler_MetallicMap,input.uv).r * _Metallic;
    customSurfaceData.metallic = saturate(metallic);
    half roughness = SAMPLE_TEXTURE2D(_RoughnessMap,sampler_RoughnessMap,input.uv).r * _Roughness;
    customSurfaceData.roughness = max(saturate(roughness),0.001f);
    
    //normalTS (tangent Space)
    float4 normalTS = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,input.uv);
    customSurfaceData.normalTS =  UnpackNormalScale(normalTS,_Normal);

    //occlusion
    half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap,sampler_OcclusionMap,input.uv).r;
    customSurfaceData.occlusion = lerp(1.0,occlusion,_OcclusionStrength);
}

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;
    output.positionWS = vertexInput.positionWS;
    output.shadowCoord = GetShadowCoord(vertexInput);
    output.positionCS = vertexInput.positionCS;

    return output;
}

half4 SimpleLitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);

    CustomLitData customLitData;
    InitializeCustomLitData(input,customLitData);

    CustomSurfacedata customSurfaceData;
    InitializeCustomSurfaceData(input,customSurfaceData);

    half4 color = PBR.SimpleLit(customLitData,customSurfaceData,input.positionWS,input.shadowCoord,_EnvRotation);
    
    return color;
}

half4 StandardLitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);

    CustomLitData customLitData;
    InitializeCustomLitData(input,customLitData);

    CustomSurfacedata customSurfaceData;
    InitializeCustomSurfaceData(input,customSurfaceData);

    half4 color = PBR.StandardLit(customLitData,customSurfaceData,input.positionWS,input.shadowCoord,_EnvRotation);
    
    return color;
}

#endif