FROM python:3.8

WORKDIR /app

# install dependencies
COPY ../hf_vision_model_onnx_gke/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

# copy fastAPI app codebase
COPY ../hf_vision_model_onnx_gke/main.py /app/main.py
COPY ../hf_vision_model_onnx_gke/utils.py /app/utils.py

# copy the onnx model file
COPY ../hf_vision_model_onnx_gke/vit-base-patch16-224.onnx /app/vit-base-patch16-224.onnx

# run the fastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]