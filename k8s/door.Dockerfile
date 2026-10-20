FROM docker-lab-k8s-linux

ENV DEBIAN_FRONTEND=noninteractive

# Door VM: apt nginx is already installed. Do not join Kubernetes.
RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/nginx/sites-enabled/default \
 && systemctl enable nginx

COPY k8s/nginx.conf /etc/nginx/nginx.conf
