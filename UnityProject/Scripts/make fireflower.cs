using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class makefireflower : MonoBehaviour
{
    MeshFilter filt;
    MeshRenderer rend;
    [SerializeField]
    Material mat;

    private int state = 0;
    private Vector3 gravity = new Vector3(0f, -1f, 0f);
    // どの程度打ちあがっているのか
    private float upRate = 0;
    // 打ちあがって開くときの高さ
    // [SerializeField, Range(0f, 10f)]
    // private float height = 1f;
    // 打ち上げ中の{invisible, visible, invisible}の割合
    private float[] upState = new float[] {0f, 0.5f, 0.8f};
    // 打ち上げ速度
    [SerializeField]
    private Vector3 upInitVelocity = new Vector3(0f, 2f, 0f);
    private Vector3 upVelocity;
    private Vector3 upPosition;
    private float mass = 1f;

    // Start is called before the first frame update
    void Start()
    {
        if (TryGetComponent<MeshFilter>(out MeshFilter mf))
        {
            filt = mf;
        }
        else
        {
            filt = this.gameObject.AddComponent<MeshFilter>();
        }
        if (TryGetComponent<MeshRenderer>(out MeshRenderer mr))
        {
            rend = mr;
        }
        else
        {
            rend = this.gameObject.AddComponent<MeshRenderer>();
        }
        // up state: 1
        state = 1;
    }

    void setParams()
    {
        upVelocity = upInitVelocity;
        upPosition = new Vector3(0f, 0f, 0f);
    }

    // Update is called once per frame
    void Update()
    {
        switch (state)
        {
            // 打ちあがる前
            case 0:
                break;
            // 打ち上げ中
            case 1:
                DrawUp();
                break;
        }
    }

    void DrawUp()
    {
        UpdateUpParams();
        Mesh mesh = MakeUpMesh();
        filt.mesh = mesh;
        rend.material = mat;

    }

    void UpdateUpParams()
    {
        float time = Time.deltaTime;
        Vector3 acceleration = mass*gravity;
        upPosition += upVelocity*time;
        upVelocity += acceleration*time;
        Vector3.Dot(gravity, upVelocity);
    }

    Mesh MakeUpMesh()
    {
        Mesh mesh = new Mesh();
        float rad = 0.01f*mass;
        float hei = 0.05f*mass;
        var vertices = new Vector3[]{
            new Vector3(-rad, 0f, +rad),
            new Vector3(+rad, 0f, +rad),
            new Vector3(+rad, 0f, -rad),
            new Vector3(-rad, 0f, -rad),
            new Vector3(0f, -hei, 0f),
        };
        var normals = new Vector3[]{
            new Vector3(0f, 1f, 0f),
            new Vector3(0f, 1f, 0f),
            new Vector3(0f, 1f, 0f),
            new Vector3(0f, 1f, 0f),
            new Vector3(0f, -1f, 0f),
        };
        var triangles = new int[]{
            0, 1, 2,
            0, 2, 3,
            1, 0, 4,
            2, 1, 4,
            3, 2, 4,
            0, 3, 4,
        };
        mesh.vertices = vertices;
        mesh.normals = normals;
        mesh.triangles = triangles;
        return mesh;
    }
}
