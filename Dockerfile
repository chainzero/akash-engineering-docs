FROM node:16 as build
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
ENV REACT_APP_NAME=AkashCaseEntry
RUN npm run build

FROM nginx:1.22
COPY --from=build /app/build /usr/share/nginx/html

