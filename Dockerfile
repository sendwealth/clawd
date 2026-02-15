# Placeholder Dockerfile for clawd workspace
# This is a basic setup - update based on your actual application needs

FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files (if they exist)
COPY package*.json ./

# Install dependencies (if package.json exists)
RUN if [ -f package.json ]; then npm install; else echo "No package.json found, skipping npm install"; fi

# Copy application files
COPY . .

# Expose port
EXPOSE 3000

# Start command - customize based on your actual application
CMD ["/bin/sh", "-c", "if [ -f package.json ]; then npm start; elif [ -f index.js ]; then node index.js; else echo 'Clawd workspace running - add your application code here' && sleep 3600; fi"]
