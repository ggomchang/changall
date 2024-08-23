FROM alpine

WORKDIR /app

COPY . .

RUN apk add libc6-compat
RUN chmod +x ./customer
RUN apk add --update curl

CMD ["./customer"]