ARG NODE_IMAGE=node:16.13.1-alpine
ARG PORT=3333

FROM $NODE_IMAGE AS base
RUN apk --no-cache add dumb-init
RUN npm i -g pnpm
RUN mkdir -p /home/node/app && chown node:node /home/node/app

USER node
WORKDIR /home/node/app
RUN mkdir tmp

FROM base AS dependencies
COPY --chown=node:node ./package.json .
COPY --chown=node:node ./pnpm-lock.yaml ./
COPY --chown=node:node . .


FROM dependencies AS build
RUN pnpm install
RUN node ace build --production


FROM base AS production
RUN true
COPY --chown=node:node --from=build /home/node/app/build .

RUN true
COPY --chown=node:node ./package.json .

RUN true
COPY --chown=node:node ./pnpm-lock.yaml .

RUN pnpm install --prefer-offline
EXPOSE $PORT
CMD [ "dumb-init", "node", "server.js" ]
