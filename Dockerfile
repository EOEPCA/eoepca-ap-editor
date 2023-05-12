# build stage
FROM node:14-buster as build-stage
WORKDIR /app
COPY frontend/package*.json frontend/yarn.lock ./
RUN yarn install
COPY frontend ./
RUN yarn run build

# production stage
FROM python:3.12-rc-slim as production-stage
RUN apt-get -y update && apt-get -y install nginx supervisor curl
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
COPY backend/ /app/backend/
WORKDIR /app/backend/
RUN pip install -r requirements.txt

COPY server.conf /etc/nginx/sites-available/default
COPY --from=build-stage /app/dist /usr/share/nginx/html

COPY supervisord.conf /etc/supervisor/supervisord.conf

ARG PUID=2000
ARG PGID=2000


RUN addgroup --gid ${PGID} ap-editor && \
    adduser --system --uid ${PUID} --gid ${PGID} ap-editor && \
    chown -R ap-editor:ap-editor /app

ENV AP_EDITOR_FILES_DIRECTORY=/app/backend/files/
EXPOSE 80

CMD ["supervisord"]
