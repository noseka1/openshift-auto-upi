#!/bin/bash -x

set -e

IGNITION_DIR={{ helper.install_ignition_dir }}

{% for host in openshift_cluster_hosts %}
HOSTNAME={{ host.hostname }}

{% if host.ignition_transform is defined %}

{% if host.ignition_transform.filetranspiler_roots is defined and host.ignition_transform.filetranspiler_roots %}
{% for item in host.ignition_transform.filetranspiler_roots %}
podman run \
  --rm \
  --volume $IGNITION_DIR:/srv/ignition:z \
  --volume {{ playbook_dir }}/{{ item }}:/srv/fakeroot:z \
  localhost/filetranspiler \
  --ignition /srv/ignition/$HOSTNAME.ign \
  --fake-root /srv/fakeroot \
  --output /srv/ignition/$HOSTNAME.ign.tmp
mv $IGNITION_DIR/$HOSTNAME.ign.tmp $IGNITION_DIR/$HOSTNAME.ign
{% endfor %}
{% endif %}

{% if host.ignition_transform.jsonpatches is defined and host.ignition_transform.jsonpatches %}
{% for item in host.ignition_transform.jsonpatches %}
jsonpatch \
  --in-place $IGNITION_DIR/$HOSTNAME.ign \
  {{ playbook_dir }}/{{ item }}
{% endfor %}
{% endif %}

{% endif %}

{% endfor %}
