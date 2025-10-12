# Use Nginx as the base image
FROM nginx:alpine


# Copy our static files into the container
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 89

# Start Nginx (this is the default CMD anyway)
CMD ["nginx", "-g", "daemon off;"]
