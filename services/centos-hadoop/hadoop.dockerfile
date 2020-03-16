FROM guojohnny/centos:hadoop-base
LABEL maintainer="guojohnny@chihan.me"
LABEL description="ADD hadoop startup bash"

COPY hadoop-entrypoint.sh /usr/bin/
RUN chmod a+x /usr/bin/hadoop-entrypoint.sh

ENTRYPOINT [ "sh", "-c", "./usr/bin/hadoop-entrypoint.sh; bash"]