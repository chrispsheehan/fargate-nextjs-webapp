FROM node:20

WORKDIR /app  

COPY ./src /app

RUN npm i

RUN npm run build --prefix /app

EXPOSE 3000  

CMD ["npm", "run", "start"]