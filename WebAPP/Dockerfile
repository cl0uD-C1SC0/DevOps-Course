FROM node:latest
WORKDIR /app
COPY . . 
RUN npm install -s express \
    npm install -s mongoose \
    npm install -s body-parser \
    npm install -s socket.io \
    npm install -s http \
    npm install -s dotenv
EXPOSE 3000
CMD ["node", "./server.js"]