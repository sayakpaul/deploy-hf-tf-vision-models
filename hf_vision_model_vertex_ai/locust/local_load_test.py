"""
User client for Locust for testing Vertex AI endpoints.
Code modified from https://bit.ly/3bUIyfl
"""

import json
import logging
import os
import time
from functools import partial
from typing import Dict, List

import google.auth
from google.auth.transport.requests import AuthorizedSession
from locust import User, constant, events

PROJECT_ID = os.environ["GCP_PROJECT"]
REGION = os.environ["REGION"]
ENDPOINT_ID = os.environ["ENDPOINT_ID"]
JSON_PAYLOAD = os.environ["JSON_PAYLOAD"]


class AIPPClient(object):
    """
    A convenience wrapper around AI Platform Prediction REST API.
    """

    def __init__(self, service_endpoint):
        logging.info(
            f"Setting the AI Platform Prediction service endpoint: {service_endpoint}"
        )
        credentials, _ = google.auth.default()
        self._authed_session = AuthorizedSession(credentials)
        self._service_endpoint = service_endpoint

    def predict(
        self,
        project_id: str,
        region: str,
        endpoint_id: str,
        instances,
    ):
        """
        Invokes the predict method on the specified signature.
        `instances` is supposed to be a JSON string.
        """

        url = "{}/v1/projects/{}/locations/{}/endpoints/{}:predict".format(
            self._service_endpoint, project_id, region, endpoint_id
        )
        logging.info(f"Obtaining predictions with URL: {url}.")
        response = self._authed_session.post(url, data=instances)
        return response


def predict_task(
    user: object,
    project_id: str,
    model: str,
    region: str,
    endpoint_id: str,
    version: str,
    instances: Dict[str, List[str]],
):
    """
    Calls a predict method on AIPP endpoint and tracks
    the response latency and status with Locust.
    """
    model_deployment_name = "{}-{}".format(model, version)
    start_time = time.time()
    try:
        response = user.client.predict(
            project_id=project_id,
            region=region,
            endpoint_id=endpoint_id,
            instances=json.dumps(instances),
        )
    except Exception as e:
        total_time = int((time.time() - start_time) * 1000)
        events.request_failure.fire(
            request_type=model_deployment_name,
            response_time=total_time,
            response_length=0,
            exception=e,
            name=model_deployment_name,
        )
        logging.error(f"Exception while querying the endpoint: {e}")
    else:
        total_time = int((time.time() - start_time) * 1000)
        if "error" in response.json():
            events.request_failure.fire(
                request_type=model_deployment_name,
                response_time=total_time,
                response_length=len(response.text),
                exception=response.text,
                name=model_deployment_name,
            )
            logging.info(f"Response: {response.json()}")
        else:
            events.request_success.fire(
                request_type=model_deployment_name,
                response_time=total_time,
                response_length=len(response.text),
                name=model_deployment_name,
            )


class ClassificationUser(User):
    wait_time = constant(1)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.client = AIPPClient(self.environment.host)

    def on_start(self):
        with open(JSON_PAYLOAD, "rb") as f:
            payload = json.load(f)

        self.tasks.clear()
        task_fn = partial(
            predict_task,
            project_id=PROJECT_ID,
            model="vit_classification",
            region=REGION,
            endpoint_id=ENDPOINT_ID,
            version="v1",
            instances=payload,
        )
        task_fn.__name__ = "predict"
        self.tasks.append(task_fn)

    def on_stop(self):
        self.tasks.clear()