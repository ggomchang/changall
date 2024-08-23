FROM python:3.12-alpine

WORKDIR /app

COPY . .

RUN pip3 install flask
RUN apk add --update curl
RUN mkdir /logs

CMD ["python3", "app.py"]