FROM node:16-slim as base

USER node

#RUN npm --location=global config set user $USER
RUN mkdir /home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

RUN npm install npm@latest --location=global

# install pnpm
RUN npm i --location=global pnpm
WORKDIR /home/node
COPY package.json  pnpm-lock.yaml ./


RUN pnpm install

COPY . .

EXPOSE 3333

CMD ["pnpm", "build", "&", "pnpm", "start"]
