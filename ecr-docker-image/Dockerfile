FROM alpine:3.14

LABEL author="Yogesh Ingale <yogeshingale94@gmail.com>"

COPY . /mnt

USER root

RUN apk add --no-cache bash \
      ca-certificates \
      curl \
      git \
      openssl \
      openssh-client \
      openssl-dev \
      rsync \
      wget \
      httpie \
      terraform \
      jq \
  && rm -rf /var/cache/apk/* \

USER worker

WORKDIR /mnt

CMD ["/mnt/task.sh"]
