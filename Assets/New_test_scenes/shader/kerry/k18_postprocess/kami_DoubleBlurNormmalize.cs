﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class kami_DoubleBlurNormmalize : MonoBehaviour
{
    public Material material;

    [Range(0, 10)]
    public float _BlurOffset = 1.0f;

    [Range(0, 10)]
    public int _iteration = 4;

    public float _Downsample = 1;

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
        int width = (int)(source.width / _Downsample);
        int height = (int)(source.height / _Downsample);

        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        Graphics.Blit(source, RT1);

        material.SetVector("_BlurOffset", new Vector4(_BlurOffset / width, _BlurOffset / height, 0, 0));

        //降采样
        for (int i = 0; i < _iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            width = width / 2;
            height = height / 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, material, 0);

            RenderTexture.ReleaseTemporary(RT1);
            width = width / 2;
            height = height / 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, material, 0);
        }

        //升采样
        for (int i = 0; i < _iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            width = width * 2;
            height = height * 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, material, 0);

            RenderTexture.ReleaseTemporary(RT1);
            width = width * 2;
            height = height * 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, material, 0);
        }

        Graphics.Blit(RT1, destination);

        //release
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
