FROM amazon/aws-cli:2.15.21

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG PLATFORM="linux_64bit"
ARG PACKER_VERSION="1.8.5"

VOLUME ["/work"]

WORKDIR /work

RUN yum -y install \
        openssh-server-7.4p1-22.amzn2.0.6.x86_64 \
        openssh-clients-7.4p1-22.amzn2.0.6.x86_64 \
        yum-utils-1.1.31-46.amzn2.0.1 \
        gcc-7.3.1-17.amzn2 \
        make-1:3.82-24.amzn2 \
        wget-1.14-18.amzn2.1 \
        curl-8.3.0-1.amzn2.0.5.x86_64 \
        tar-2:1.26-35.amzn2.0.3 \
        python3-3.7.16-1.amzn2.0.4\
        unzip-6.0-57.amzn2.0.1 \
        genisoimage-1.1.11-23.amzn2.0.2 \
        zlib1g-dev && \
    yum clean all && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python2 /usr/bin/python

RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then PLATFORM="linux_arm64"; fi; \
    wget --progress=dot:giga "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/$PLATFORM/session-manager-plugin.rpm" && \
    yum install -y session-manager-plugin.rpm && \
    rm -rf session-manager-plugin.rpm && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
    yum clean all

RUN wget --progress=dot:giga "https://bootstrap.pypa.io/pip/get-pip.py" && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python get-pip.py  && \
    rm get-pip.py && \
    pip3 install --no-cache-dir ansible paramiko hvac

RUN wget --progress=dot:giga "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
    unzip "packer_${PACKER_VERSION}_linux_amd64.zip" && \
    mv packer /usr/bin/packer && \
    rm /usr/sbin/packer && \
    ln -s /usr/bin/packer /usr/sbin/packer && \
    rm -rf "packer_${PACKER_VERSION}_linux_amd64.zip"

ENTRYPOINT [ "packer" ]

CMD [ "--version" ]
