#!/bin/sh
oc adm release mirror \
  --registry-config {{ helper.mirror_registry_dir }}/pull-secret.json \
  --from {{ mirror_registry.mirror_from }} \
  --to {{ mirror_registry.mirror_to }}
