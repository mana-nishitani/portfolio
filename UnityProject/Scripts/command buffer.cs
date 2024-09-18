using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]

public class commandbuffer : MonoBehaviour
{
    [SerializeField]
    private Material material;
    [SerializeField]
    private Camera myCamera;

    private void Awake()
    {
        var commandBuffer = new CommandBuffer();

        int tmpTextureIdentifier = Shader.PropertyToID("post effect");
        commandBuffer.GetTemporaryRT(tmpTextureIdentifier, -1, -1);
        commandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, tmpTextureIdentifier);

        commandBuffer.Blit(tmpTextureIdentifier, BuiltinRenderTextureType.CameraTarget, material);

        commandBuffer.ReleaseTemporaryRT(tmpTextureIdentifier);

        myCamera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }
}
