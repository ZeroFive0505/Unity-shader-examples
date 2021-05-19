using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Circle : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }


    public float radius = 2.0f;

    // Update is called once per frame
    void Update()
    {
        float x = Mathf.Cos(Time.fixedTime) + radius;
        float y = Mathf.Sin(Time.fixedTime) + radius;
        this.transform.position = new Vector3(x, y, 0);
    }

}
