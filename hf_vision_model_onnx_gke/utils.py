import io
from typing import Dict, List

import numpy as np
from fastapi import HTTPException
from PIL import Image

TARGET_IMG_WIDTH = 224
TARGET_IMG_HEIGHT = 224
MEAN = [0.5, 0.5, 0.5]
STD = [0.5, 0.5, 0.5]


def raise_http_exception(msg):
    """Raise HTTPException with the status code 400"""
    raise HTTPException(status_code=400, detail=msg)


def normalize_img(img):
    # Scale to the value range of [0, 1] first and then normalize.
    img = img / 255
    mean = np.array(MEAN)
    std = np.array(STD)
    return (img - mean) / std


def prepare_image(image_file: bytes, with_resizing: bool = False) -> np.ndarray:
    """Prepares an image for model prediction."""
    image = Image.open(io.BytesIO(image_file))
    width, height = image.size

    if image.format not in ["JPEG", "JPG", "PNG"]:
        raise_http_exception("Supported formats are JPEG, JPG, and PNG.")

    if with_resizing:
        image = image.resize((TARGET_IMG_WIDTH, TARGET_IMG_HEIGHT))
    else:
        if width is not TARGET_IMG_WIDTH or height is not TARGET_IMG_HEIGHT:
            raise_http_exception("Image size is not 224x224")

    image = np.array(image).astype("float32")
    image = normalize_img(image)
    image = image.astype("float32")
    image = image.transpose((2, 0, 1))  # Since HF models are channel-first.
    return np.expand_dims(image, 0)


def decode_predictions(
    predictions: np.ndarray, imagenet_categories: List[str]
) -> Dict[str, float]:
    """Decodes model predictions."""
    predictions = np.squeeze(predictions)
    pred_name = imagenet_categories[int(predictions.argmax())]
    response_dict = {"Label": pred_name, "Score": f"{predictions.max():.3f}"}

    return response_dict
