# Use the official Nginx image as the base
FROM nginx:alpine

# Copy all project files to the Nginx directory
COPY . /usr/share/nginx/html

# Expose port 80 for the container
EXPOSE 80
