#ifndef Kami_Utility
#define Kami_Utility

// 三颜色（顶，侧，底）插值环境光方法
float3 TriColAmbient (float3 n, float3 uCol, float3 sCol, float dCol) {
    float uMask = max(0.0, n.g);        // 获取朝上部分遮罩
    float dMask = max(0.0, -n.g);       // 获取朝下部分遮罩
    float sMask = 1.0 - uMask - dMask;  // 获取侧面部分遮罩
    float3 envCol = uCol * uMask +
                    sCol * sMask +
                    dCol * dMask;       // 混合环境色
    return envCol;
}

//旋转CUbemap
float3 rotateAngleByArc(float degree,float3 target) {
    float rad = degree * UNITY_PI / 180;
    float2x2 m_rotate = float2x2(cos(rad),-sin(rad),sin(rad),cos(rad));
    float2 dir_rotate = mul(m_rotate,target.xz);
    target = float3(dir_rotate.x,target.y,dir_rotate.y);
    return target;
}

//tonemapping 色调映射
float3 ACESFilm(float3 x){
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
}

#endif