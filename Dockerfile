FROM ubuntu:22.04

RUN yes | unminimize

RUN apt-get -y update
RUN apt-get install -y vim

# SSH configuration

RUN apt-get install -y \
	openssh-server
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "root:changeme" | chpasswd

# Installing webssh2

RUN apt-get install -y curl git xz-utils
# Manually install nodejs as ubuntu:22.04 is not yet supported for nodejs
RUN curl https://nodejs.org/dist/v16.13.0/node-v16.13.0-linux-x64.tar.xz -o node.tar.xz
RUN mkdir -p /usr/local/lib/nodejs
RUN tar -xf node.tar.xz -C /usr/local/lib/nodejs 
ENV PATH "$PATH:/usr/local/lib/nodejs/node-v16.13.0-linux-x64/bin"
RUN npm version
RUN cd /root && git clone https://github.com/CChemin/webssh2.git
ADD webssh2-config.json /root/webssh2/app/config.json
RUN cd ~/webssh2 && git checkout default-host-at-root-path && cd ~/webssh2/app && npm install --production

VOLUME ["/root/"]
CMD /usr/sbin/sshd ; node /root/webssh2/app/index.js
EXPOSE 22 2222
