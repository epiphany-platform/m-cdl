FROM python:3.7.6-stretch

RUN pip install pip --upgrade
RUN pip install ansible

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sshpass

WORKDIR /srv/workdir
WORKDIR /workdir

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && VERIFY_CHECKSUM=false ./get_helm.sh

RUN ansible-galaxy collection install community.kubernetes

ADD ansible /srv/ansible
ADD workdir /srv/workdir
ADD resources /srv/resources
ADD helm /srv/helm


ENTRYPOINT ["/srv/workdir/start.sh"]
