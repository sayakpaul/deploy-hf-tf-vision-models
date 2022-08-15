## Contents

* `hf_tf_vision_vertex_ai.ipynb` notebook shows you how to deploy a [ViT model from 🤗 Transformers](https://huggingface.co/docs/transformers/main/en/model_doc/vit#transformers.TFViTForImageClassification) on Vertex AI.
* `test-vertex-ai-endpoint.ipynb` notebook shows you how to test a Vertex AI Endpoint without the Vertex AI SDK.
* `locust/` directory has utilities for conducting a local load-test of the model deployed on Vertex AI with [Locust](https://locust.io/). 
    
    * Set up environment variables:

        ```bash
        export GCP_PROJECT=...
        export REGION=us-central1
        export ENDPOINT_ID=...
        export JSON_PAYLOAD=single-instance.json # Change this for experimentation
        ```

    * Configure Locust-specific variables inside `load_test.conf`. 

    * Install Locust by `pip install locust`. 

    * Launch the load-test with `locust --config=load_test.conf`.

    After the load-test is done, you should see a bunch of files including `locust_report.html`. Open it to investigate 
    prediction statistics. You should similar outputs in there: 

    <div align="center">
    <img src="https://i.ibb.co/jvw710f/image.png" width=550/>
    </div>

