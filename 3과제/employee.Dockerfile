FROM alpine

WORKDIR /app

COPY . .

RUN chmod +x employee
RUN apk add libc6-compat

CMD ["./employee"]