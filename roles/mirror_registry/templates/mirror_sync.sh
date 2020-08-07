#!/bin/sh
{{ helper.oc_exe }} adm release mirror \
  --registry-config {{ helper.mirror_registry_dir }}/pull-secret.json \
  --from {{ item.value.mirror_from }} \
  --to {{ item.value.mirror_to }} \
  --to-release-image {{ item.value.mirror_to }}:{{ item.value.mirror_to_release }}
