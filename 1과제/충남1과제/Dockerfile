FROM alpine

WORKDIR /app

COPY . .

RUN apk add libc6-compat
RUN chmod +x ./customer
RUN adduser customer --disabled-password
RUN apk add --update curl

USER customer

CMD ["./customer"]