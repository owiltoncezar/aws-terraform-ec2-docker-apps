FROM node:14

WORKDIR /app
COPY package.json /app
COPY app.js /app

RUN npm install

EXPOSE 3000
CMD ["node", "app.js"]