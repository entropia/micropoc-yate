FROM debian:stretch
RUN apt-get update && apt-get install -y subversion build-essential autoconf && \
  mkdir -p /build/yate && cd /build/yate && \
  svn checkout http://yate.null.ro/svn/yate/tags/RELEASE_6_1_0/ . && \
  ./autogen.sh && \
  ./configure --prefix=/opt/yate && \
  make -j8 && \
  mkdir -p /opt/yate && \
  mkdir -p /out && \
  make install-noapi && \
  rm -rf /build
VOLUME /out
CMD tar -czf /out/yate-6.1.0.tgz -C /opt/yate .
