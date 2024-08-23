FROM python:3.12-alpine
WORKDIR /app
COPY . .
RUN pip3 install flask
RUN mkdir log
CMD ["python3", "app.py"]