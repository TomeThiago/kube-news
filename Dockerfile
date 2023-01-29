FROM node:18.11-alpine
WORKDIR /app
COPY src/package*.json ./
RUN npm install
COPY . .
CMD ["node", "src/server.js"]
EXPOSE 8080