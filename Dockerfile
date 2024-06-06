FROM debian:latest AS build
RUN apt-get update && apt-get install -y git build-essential autoconf pkg-config libssl-dev && \
  mkdir -p ~/.ssh && \
  ssh-keyscan github.com >> ~/.ssh/known_hosts && \
  mkdir -p /build/yate
RUN git clone https://github.com/yatevoip/yate.git /build/yate
COPY patches/*.patch /build/yate
RUN cd /build/yate && \
  for p in *.patch; do patch -p1 < $p; done && \
  ./autogen.sh && \
  ./configure --prefix=/opt/yate && \
  make -j8 && \
  mkdir -p /opt/yate && \
  mkdir -p /out && \
  make install-noapi && \
  rm -rf /build
VOLUME /out
CMD tar -czf /out/yate-master.tgz -C /opt/yate .

FROM debian:latest
RUN apt-get update && apt-get install -y openssl ca-certificates
COPY --from=build /opt/yate /opt/yate
RUN useradd -Umd /opt/yate -s /usr/bin/bash -u 1000 yate
RUN  chown -R yate:yate /opt/yate &&\
     rm -rf /opt/yate/etc

USER yate
WORKDIR /opt/yate
VOLUME /opt/yate/etc

ENV LD_LIBRARY_PATH=/opt/yate/lib

CMD ["/opt/yate/bin/yate", "-vvv"]
