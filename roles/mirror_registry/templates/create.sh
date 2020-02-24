#!/bin/sh
podman create \
  --name mirror-registry \
  -p {{ mirror_registry.listen_port }}:5000 \
  -v {{ helper.mirror_registry_dir }}/data:/var/lib/registry:z \
  -v {{ helper.mirror_registry_dir }}/auth:/auth:z \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v {{ helper.mirror_registry_dir }}/certs:/certs:z \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  {{ mirror_registry.container_image }}
