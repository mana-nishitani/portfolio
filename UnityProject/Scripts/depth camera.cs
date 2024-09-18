using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class depthcamera : MonoBehaviour
{
    protected new Camera camera;
    public DepthTextureMode depthTextureMode;
    void Start()
    {
        this.camera = GetComponent<Camera>();
        this.camera.depthTextureMode = this.depthTextureMode;
    }

    protected virtual void OnValidate()
    {
        if (this.camera != null)
        {
            this.camera.depthTextureMode = this.depthTextureMode;
        }
    }

}
