FROM centos:6.6
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Add SSH netools"

# 使用一个 RUN 减少镜像体积
# 为解决Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY问题
# 生成 root 
# 下载 ssh 、netools
# 设置 sshd 
# 下面这两句比较特殊，在centos6上必须要有，否则创建出来的容器sshd不能登录
# ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
# ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \

RUN rpm --import /etc/pki/rpm-gpg/RPM* \
    && yum -y install which	\
	&& yum -y install openssh-server \
	&& echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
	&& yum -y install openssh-clients \
	&& mkdir /root/.ssh \
	&& ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ''\
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
	&& cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys \
	&& echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
	&& echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
	&& chmod 600 /root/.ssh/authorized_keys \
    && mkdir /var/run/sshd 

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]