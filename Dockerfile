# Use an official Node.js runtime as a parent image
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json yarn.lock* ./
# Use yarn for potentially faster installs
RUN yarn install --frozen-lockfile --production=false

# Copy Medusa project files
COPY . .

# Build Medusa admin (if you haven't pre-built it)
# RUN yarn build:admin

# Build Medusa backend
RUN yarn build

# --- Production Stage ---
FROM node:18-alpine

WORKDIR /app

# Copy built files and production dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
# Copy other necessary files like medusa-config.js if not part of build output
# COPY --from=builder /app/medusa-config.js ./

# Expose the port Medusa runs on
EXPOSE 9000

# Run migrations and start Medusa
# Note: Running migrations on startup might not be ideal for Fargate scaling events.
# Consider a separate migration strategy (e.g., dedicated ECS task run before deployment).
# For simplicity here, we include it. Remove RUN medusa migrations run if handled elsewhere.
# CMD ["sh", "-c", "medusa migrations run && medusa start"]
CMD ["node", "dist/main.js"] # Or use `medusa start` if preferred/configured