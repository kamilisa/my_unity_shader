using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class kami_ACES_tonemapping : MonoBehaviour
{
    public Material material;

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
        Graphics.Blit(source, destination, material, 0);
    }
}
