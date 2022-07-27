import tensorflow as tf
import base64
import json
from locust import HttpUser, task, constant

class ImgClssificationUser(HttpUser):
    wait_time = constant(1)

    image_path = "./cat.jpg"
    headers = {"content-type": "application/json"}

    bytes_inputs = tf.io.read_file(image_path)
    b64str = base64.urlsafe_b64encode(bytes_inputs.numpy()).decode("utf-8")
    data = json.dumps({"signature_name": "serving_default", "instances": [b64str]})

    @task
    def predict(self):
        r = self.client.post("/v1/models/resnet:predict", data=self.data, headers=self.headers)
