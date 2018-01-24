# Use an Circle CI's ruby image (it has most of the required "stuff")
FROM nginx:1.13.8

COPY .build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
