FROM ngekaworu/basic-hugo:latest as builder

RUN mkdir -p /home/blog/app

WORKDIR /home/blog/app

COPY . .

RUN hugo

FROM nginx:stable-alpine

EXPOSE 80

COPY --from=builder /home/blog/app/public /usr/share/nginx/html