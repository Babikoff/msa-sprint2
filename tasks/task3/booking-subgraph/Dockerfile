FROM node:18

WORKDIR /app

COPY booking-subgraph/package.json ./
RUN npm install

COPY booking-subgraph/ .
COPY common/ /common/

CMD ["node", "index.js"]
