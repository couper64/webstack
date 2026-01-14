# ---- Build Stage ----
FROM node:latest AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Add the Node adapter
RUN npm install @astrojs/node

# Copy source files
COPY . .

# Build Astro for production
RUN npm run build

# ---- Runtime Stage ----
FROM node:latest
WORKDIR /app

# Copy only built files + node_modules
COPY --from=builder /app .

EXPOSE 4321

CMD ["node", "./dist/server/entry.mjs"]
