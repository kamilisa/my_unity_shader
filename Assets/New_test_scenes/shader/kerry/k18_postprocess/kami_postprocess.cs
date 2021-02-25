using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class kami_postprocess : MonoBehaviour
{
    public Material material;
    public float _ColorShift = 0;
    public float _Brightness = 1;
    public float _Saturation = 1;
    public float _Contrast = 1;
    [Range(0.05f, 3.0f)]
    public float _VignetteIntensity = 1.5f;
    [Range(1.0f, 6.0f)]
    public float _VignetteRoundness = 5.0f;
    [Range(0.05f, 5.0f)]
    public float _VignetteSmoothness = 5.0f;

    // Start is called before the first frame update
    void Start()
    {
        if (material == null)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_ColorShift", _ColorShift);
        material.SetFloat("_Brightness", _Brightness);
        material.SetFloat("_Saturation", _Saturation);
        material.SetFloat("_Contrast", _Contrast);
        material.SetFloat("_VignetteIntensity", _VignetteIntensity);
        material.SetFloat("_VignetteRoundness", _VignetteRoundness);
        material.SetFloat("_VignetteSmoothness", _VignetteSmoothness);
        Graphics.Blit(source, destination, material, 0);
    }
}
