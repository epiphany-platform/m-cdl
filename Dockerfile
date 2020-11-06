FROM ansible/centos7-ansible:stable

ADD ansible /srv/ansible
ADD workdir /srv/workdir

# COPY workdir /srv/ansible

ARG ARG_M_VERSION="unknown"

# ENV M_WORKDIR="/workdir" \
#     M_RESOURCES="/resources" \
#     M_SHARED="/shared" \
#     M_VERSION="$ARG_M_VERSION"

#ARG ARG_HOST_UID=1000
#ARG ARG_HOST_GID=1000



# EXPOSE 22 3000 80

# RUN apk add --update --no-cache make=4.3-r0 && \
#     wget https://github.com/mikefarah/yq/releases/download/3.3.4/yq_linux_amd64 -O /usr/bin/yq && \
#     chmod +x /usr/bin/yq && \
#     chown -R $ARG_HOST_UID:$ARG_HOST_GID /workdir /resources

#USER $ARG_HOST_UID:$ARG_HOST_GID

WORKDIR /srv/workdir
WORKDIR /workdir
# ENTRYPOINT ["/srv/workdir/start.sh"]
ENTRYPOINT ["/srv/workdir/start.sh"]
# RUN ansible-playbook /srv/ansible/cdldeployment.yml -i /srv/ansible/inventory.yml
