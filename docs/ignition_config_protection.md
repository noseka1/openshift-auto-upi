# Ignition Config Protection

Ignition configs include certificates and keys used by the OpenShift nodes for bootstrapping. OpenShift nodes won't be able to join the cluster if they don't have the matching certificates.

Certificates are newly generated every time the `openshift-installer create ignition-configs` command is executed. To prevent overwriting the existing ignition configs, and hence creating OpenShift nodes that won't be able to join the cluster, *openshift-auto-upi* creates a timestamp (latch) after the ignition configs are generated the first time. If this timestamp exists, *openshift-auto-upi* will skip the generation of ignition configs. This way ignition configs won't get overwritten during the following runs of *openshift-auto-upi*.

If you want to scrub your ignition configs and start over using a newly generated ignition configs, you have to do the following:

Wipe out the existing cluster configuration:

```
$ ansible-playbook delete_install_config.yml
```
