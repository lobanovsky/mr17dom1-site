FROM nginx:stable-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY mr17dom1-from-tilda/ /usr/share/nginx/html/
RUN rm -f /usr/share/nginx/html/htaccess /usr/share/nginx/html/readme.txt \
    && rm -rf /usr/share/nginx/html/files \
    && nginx -t
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1

