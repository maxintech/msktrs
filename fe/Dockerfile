FROM nginx:1.21.0
WORKDIR /etc/nginx/
# Remove default configuration files
RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
# Add static files
ADD ./src /etc/nginx/html
# Add configuration template
ADD nginx.conf /tmp/nginx.template
# Add run script
ADD run.sh .
CMD ./run.sh