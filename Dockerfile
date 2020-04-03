FROM ubuntu:18.04

RUN yes | unminimize

RUN apt-get -y update

# SSH configuration

RUN apt-get install -y \
	openssh-server
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "root:changeme" | chpasswd

# Installing webssh2

RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN apt-get install -y git
RUN cd /root && git clone https://github.com/CChemin/webssh2.git
ADD webssh2-config.json /root/webssh2/app/config.json
RUN cd ~/webssh2 && git checkout default-host-at-root-path && cd ~/webssh2/app && npm install --production

# Installing s3cmd

RUN wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -
RUN wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list
RUN apt install -y s3cmd

# Installing vault

RUN apt-get install -y unzip
RUN cd /usr/bin && \
    wget https://releases.hashicorp.com/vault/1.3.4/vault_1.3.4_linux_amd64.zip && \
    unzip vault_1.3.4_linux_amd64.zip && \
    rm vault_1.3.4_linux_amd64.zip
RUN vault -autocomplete-install

VOLUME ["/root/"]
CMD /usr/sbin/sshd ; /usr/bin/node /root/webssh2/app/index.js
EXPOSE 22 2222
