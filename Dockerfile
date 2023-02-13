FROM amazon/aws-cli

RUN yum -y install openssh-server openssh-clients yum-utils gcc make zlib1g-dev wget curl tar python3 && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python2 /usr/bin/python && \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
    yum install -y session-manager-plugin.rpm && \
    rm -rf session-manager-plugin.rpm

RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

RUN yum -y install packer && \
    rm -rf /usr/sbin/packer && \
    ln -s /usr/bin/packer /usr/sbin/packer

RUN wget https://bootstrap.pypa.io/pip/get-pip.py && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python get-pip.py  && \ 
    pip3 install ansible    

ENTRYPOINT [ "packer" ]

CMD [ "--version" ]