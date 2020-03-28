FROM mysql:5.7.17
LABEL maintainer="guojohnny@chihan.me"
LABEL description="build mysql5.7.17"

#####################################
# Set Timezone#
####################################
ENV TZ=UTC

RUN echo $TZ > /etc/timezone && chown -R mysql:root /var/lib/mysql/

COPY my.cnf /etc/mysql/conf.d/my.cnf

CMD ["mysqld"]

EXPOSE 3306