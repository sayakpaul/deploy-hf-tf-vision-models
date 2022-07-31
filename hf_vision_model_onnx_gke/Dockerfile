FROM python:3.8

WORKDIR /app

# install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

# copy fastAPI app codebase
COPY main.py /app/main.py
COPY utils.py /app/utils.py

# copy the onnx model file
COPY vit-base-patch16-224.onnx /app/vit-base-patch16-224.onnx

# run the fastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]