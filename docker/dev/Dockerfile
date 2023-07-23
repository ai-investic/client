ARG CLIENT_CONTAINER_PORT
ARG NODE_VERSION

FROM node:${NODE_VERSION}

SHELL ["/bin/bash", "-c"]
WORKDIR "/client"

COPY package.json .

RUN apt update -q \
  && apt upgrade -qy \
  && npm i -g pnpm

EXPOSE ${CLIENT_CONTAINER_PORT}

ENTRYPOINT ["/bin/bash", "-c", "pnpm i && pnpm dev --port=5000 --host=0.0.0.0"]
