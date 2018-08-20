FROM zuohuadong/caddy:alpine

LABEL maintainer="Huadong Zuo <admin@zuohuadong.cn>"

# ARG plugins="cors"

# ARG plugins="cors cgi cloudflare azure linode"
ARG plugins="cors digitalocean"


RUN caddyplug install ${plugins}
    

EXPOSE 80 443 2015

WORKDIR /var/www/public

CMD ["/usr/bin/caddy", "-conf", "/etc/Caddyfile","-agree"]
