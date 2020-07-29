FROM node:12 as builder
WORKDIR /guestbook-client
COPY . /guestbook-client
RUN yarn
RUN yarn build

# allows the static CRA app to use runtime environment variables, see:
# https://github.com/andrewmclagan/react-env/blob/master/examples/create-react-app/README.md#deploying-in-production
FROM beamaustralia/react-env
WORKDIR /var/www
COPY --from=builder /guestbook-client/build /var/www
