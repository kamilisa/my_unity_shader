using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class kami_customBloom : MonoBehaviour
{
    public Material material;

    [Range(0, 10)]
    public float _threshold = 1.0f;

    [Range(0, 10)]
    public float _intensity = 1.0f;

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
        material.SetFloat("_threshold", _threshold);
        float intensity = Mathf.Exp(_intensity / 10.0f * 0.693f) - 1.0f;
        material.SetFloat("_intensity", intensity);

        RenderTexture RT1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        RenderTexture RT2 = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
        RenderTexture RT3 = RenderTexture.GetTemporary(source.width / 8, source.height / 8, 0, source.format);
        RenderTexture RT4 = RenderTexture.GetTemporary(source.width / 16, source.height / 16, 0, source.format);
        RenderTexture RT5 = RenderTexture.GetTemporary(source.width / 8, source.height / 8, 0, source.format);
        RenderTexture RT6 = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
        RenderTexture RT7 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        RenderTexture[] RT_list = new RenderTexture[] { RT1, RT2, RT3, RT4, RT5, RT6, RT7 };

        //阈值
        Graphics.Blit(source, RT1, material, 0);
        //模糊（降采样）
        Graphics.Blit(RT1, RT2, material, 1);
        Graphics.Blit(RT2, RT3, material, 1);
        Graphics.Blit(RT3, RT4, material, 1);
        //模糊（升采样）
        material.SetTexture("_BloomTex", RT3);
        Graphics.Blit(RT4, RT5, material, 2);
        material.SetTexture("_BloomTex", RT2);
        Graphics.Blit(RT5, RT6, material, 2);
        material.SetTexture("_BloomTex", RT1);
        Graphics.Blit(RT6, RT7, material, 2);

        //合并
        material.SetTexture("_BloomTex", RT7);
        Graphics.Blit(source, destination, material,3);

        //release

        for (int i = 0; i < RT_list.Length; i++)
        {
            RenderTexture.ReleaseTemporary(RT_list[i]);
        }

    }
}
