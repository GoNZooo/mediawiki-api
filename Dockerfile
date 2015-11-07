FROM gonz/racket
MAINTAINER Rickard Andersson <gonz@severnatazvezda.com>

# Copy movie-star source to filesystem
COPY src /wiki-page-src
WORKDIR /wiki-page-src

EXPOSE 8082
CMD ["racket", "web-start.rkt"]

