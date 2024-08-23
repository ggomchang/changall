FROM alpine

WORKDIR /app

COPY . .

RUN chmod +x token
RUN apk add libc6-compat

CMD ["./token"]