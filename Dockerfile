FROM nginx

# Install unzip if it's not already available
# For Alpine-based images
# RUN apk add --no-cache unzip  
# For Debian/Ubuntu-based images
RUN apt-get update && apt-get install -y unzip  
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

COPY ./rego_bundle.zip /var/www/

# Unzip the contents into the target directory
RUN unzip /var/www/rego_bundle.zip -d /var/www

RUN rm /var/www/rego_bundle.zip

# docker build -t opa-test-report 
# docker run -p 8080:80 opa-test-report