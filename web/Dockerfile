FROM oven/bun:1 AS base
WORKDIR /usr/src/app

FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lock /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

ENV NODE_ENV=production
RUN bun run build

# copy production dependencies and source code into final image
FROM base AS release
COPY --from=prerelease /usr/src/app/serve.ts ./serve.ts
COPY --from=prerelease /usr/src/app/dist ./dist

# run the app
USER bun
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "run", "serve.ts" ]
