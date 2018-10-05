#!/bin/sh

set -e

NGINX_VERSION=1.14.0

rm -rf docker-nginx
git clone https://github.com/nginxinc/docker-nginx.git

cd docker-nginx
git checkout $NGINX_VERSION

cd stable/alpine

sed '/ENV NGINX_VERSION/s/.*/&\
ENV NGX_BROTLI_COMMIT e26248ee361c04e25f581b92b85d95681bdffb39/' Dockerfile > tmp1

sed '/CONFIG=/s/.*/\&\& apk add --no-cache --virtual .brotli-build-deps \\\
		autoconf \\\
		libtool \\\
		automake \\\
		git \\\
		g++ \\\
		cmake \\\
	\&\& mkdir -p \/usr\/src \\\
	\&\& cd \/usr\/src \\\
	\&\& git clone --recursive https:\/\/github.com\/eustas\/ngx_brotli.git \\\
	\&\& cd ngx_brotli \\\
	\&\& git checkout -b $NGX_BROTLI_COMMIT $NGX_BROTLI_COMMIT \\\
	\&\& CONFIG="\\\
		--add-module=\/usr\/src\/ngx_brotli \\\ /' tmp1 > tmp2

sed '/rm -rf \/usr\/src/s/.*/&\
	\&\& rm -rf \/usr\/src\/ngx_brotli \\\
	\&\& apk del .brotli-build-deps \\\ /' tmp2 > Dockerfile

rm tmp*

docker build -t dockerhub.io-labs.de:443/cospired/docker/nginx_brotli:latest -t dockerhub.io-labs.de:443/cospired/docker/nginx_brotli:$NGINX_VERSION .
docker push dockerhub.io-labs.de:443/cospired/docker/nginx_brotli