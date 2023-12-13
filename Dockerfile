FROM node:lts-alpine AS base
WORKDIR /app

RUN apk add --no-cache git

COPY package*.json .
COPY README.md .
COPY astro.config.mjs .
COPY .gitignore .
COPY .git ./.git
COPY src ./src
COPY public ./public
COPY Dockerfile .dockerignore ./

FROM base AS prod-deps
RUN npm install --production

FROM base AS build-deps
RUN npm install --production=false

FROM build-deps AS build
COPY . .
RUN npm run build

FROM base AS runtime
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

CMD npm start 