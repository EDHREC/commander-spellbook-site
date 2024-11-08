# syntax=docker/dockerfile:1
FROM node:23-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat \
    build-base \
    g++ \
    cairo \
    librsvg-dev \
    pango-dev \
    imagemagick \
    fontconfig \
    font-noto 
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# If running docker build locally create a .github_token file with the following
# <yourGitHubToken>
# Then run the following command to build the image
#    docker build --secret id=github_token,src=.github_token -t spellbook-client:latest .
# Which you can run with
#    docker run -p 3000:3000 spellbook-client:latest
RUN --mount=type=secret,required=true,id=github_token,env=GITHUB_TOKEN \
    echo '@spacecowmedia:registry="https://npm.pkg.github.com"' >> .npmrc && \
    echo "//npm.pkg.github.com/:_authToken=$GITHUB_TOKEN" >> .npmrc && \
    if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
    else echo "Lockfile not found." && exit 101; \
    fi && \
    rm -f .npmrc


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
ENV NEXT_TELEMETRY_DISABLED=1

ARG build_type=prod
ENV BUILD_TYPE=$build_type
RUN yarn install
RUN yarn build

# If using npm comment out above and use below instead
# RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner

#deps for canvas
RUN apk add --no-cache build-base \
    cairo \
    pango \
    librsvg \
    fontconfig \
    font-noto 

# Ensure symbolic links for musl compatibility
RUN ln -s /usr/lib/libcairo.so.2 /usr/lib/libcairo.so || true && \
    ln -s /usr/lib/libpango-1.0.so.0 /usr/lib/libpango-1.0.so || true && \
    ln -s /usr/lib/libjpeg.so /usr/lib/libjpeg.so.8 || true

WORKDIR /app

ARG build_type=prod
ENV BUILD_TYPE=$build_type
ENV NODE_ENV=production

ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
# set hostname to localhost
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
