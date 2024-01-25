FROM nginx:mainline-alpine
RUN rm /etc/nginx/conf.d/*
ADD src/helloworld.conf /etc/nginx/conf.d/
ADD src/index.html /usr/share/nginx/html/