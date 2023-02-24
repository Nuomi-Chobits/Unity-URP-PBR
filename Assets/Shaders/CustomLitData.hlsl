#ifndef CUSTOM_LIT_DATA_INCLUDED
#define CUSTOM_LIT_DATA_INCLUDED

struct CustomLitData
{
    float3 positionWS;
    half3  V; //ViewDirWS
    half3  N; //NormalWS
    half3  B; //BinormalWS
    half3  T; //TangentWS
    float2 ScreenUV;
};

struct CustomSurfacedata
{
    half3 albedo;
    half3 specular;
    half3 normalTS;
    half  metallic;
    half  roughness;
    half  occlusion;
    half  alpha;
};

#endif