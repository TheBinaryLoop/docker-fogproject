FROM ubuntu:latest
LABEL maintainer="TheBinaryLoop"
LABEL Name=fogproject Version=1.5.7

ENV VERSION=1.5.7

RUN apt update && apt upgrade -y && apt install -y \
    clamav \
    clamav-daemon \
    wget \
    iproute2 \
    software-properties-common \
    language-pack-en \
    jq

RUN wget -4 https://github.com/FOGProject/fogproject/archive/${VERSION}.tar.gz \
 && tar xvfz ${VERSION}.tar.gz \
 && cd fogproject-${VERSION}/bin \
 && mkdir -p /backup \
 && bash ./installfog.sh --autoaccept

# force redirect to FOG root URL from Apache base URL's
COPY assets/index.php /var/www
COPY assets/index.php /var/www/html
RUN rm /var/www/html/index.html

# patch vsftpd init file because start with failure
ADD assets/vsftpd.patch .
RUN patch /etc/init.d/vsftpd vsftpd.patch && rm -f vsftpd.patch

# remove FOG sources
RUN rm -rf /fogproject-* /${VERSION}.tar.gz

# saving default data
RUN mkdir -p /opt/fog/default/
RUN cp -rp /var/lib/mysql /opt/fog/default/
RUN cp -rp /images /opt/fog/default/

RUN touch /INIT
ADD assets/entry.sh .
CMD bash entry.sh
