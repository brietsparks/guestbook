FROM node:12 as builder
WORKDIR /guestbook-client
COPY . /guestbook-client
RUN yarn
RUN yarn build

FROM nginx:1.12-alpine
COPY --from=builder /guestbook-client/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
