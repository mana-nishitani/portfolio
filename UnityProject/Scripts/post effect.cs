using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]

public class posteffect : MonoBehaviour
{
    public Material material;

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture target)
    {
        // RenderTexture tmp = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, target, material);
        // Graphics.Blit(tmp, target, material, 1);
        // RenderTexture.ReleaseTemporary(tmp);
    }
}
