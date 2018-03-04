FROM resin/rpi-raspbian

RUN \
  apt-get update && \
  apt-get install -y -q --no-install-recommends ca-certificates \ 
  git nginx gettext-base python3 python3-setuptools python3-dev \
  python3-pip build-essential \
  python python-dev python-setuptools && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY ./app /app
WORKDIR /app
COPY requirements.txt /app/requirements.txt

# RUN easy_install pip
RUN pip3 install -r requirements.txt

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443
# Finished setting up Nginx

# Make NGINX run on the foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# kill default page
RUN rm /etc/nginx/sites-enabled/default

# Copy the modified Nginx conf
COPY nginx.conf /etc/nginx/conf.d/

# Install Supervisord
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

# RUN apt-get update && apt-get install certbot && rm -rf /var/lib/apt/lists/*

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


CMD ["/usr/bin/supervisord"]
