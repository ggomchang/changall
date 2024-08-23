from public.ecr.aws/docker/library/python:3.12-alpine3.20

run mkdir /app
workdir /app

copy ./src/*.py ./

run pip install flask

cmd ["python3", "./app.py"]
