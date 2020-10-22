#FROM node:14-alpine

#USER nobody

# ensure all directories exist
#WORKDIR /app

#EXPOSE 3000

#CMD ["node", "schema-registry.js"]

#------------------------
FROM node:14-alpine

ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

COPY . .

RUN npm install
RUN npm install rimraf
RUN npm run build

EXPOSE 3000

CMD ["node", "schema-registry.js"]
