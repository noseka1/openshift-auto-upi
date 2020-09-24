# Making control-plane unschedulable

The control plane, or master, machines are set schedulable by default and application pods run on the master nodes.
There're two options as follows to prevent pods from being scheduled on the control plane machines.
* [Modify the <installation_directory>/manifests/cluster-scheduler-02-config.yml Kubernetes manifest file](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-generate-k8s-manifest-ignition_installing-bare-metal) after generating the Kubernetes manifests. 
* Place the scheduler policy file either before or after generating the Kubernetes manifests.

To place the scheduler policy file, create tha manifests directory and place the policy file before installing the cluster with `openshift_baremetal.yml` or `openshift_libvirt_pxe.yml`.
```
export CLUSTER_NAME=$(awk '/name: / {print $2}' ~/openshift-auto-upi/inventory/group_vars/all/openshift_install_config.yml)
ansible helper -m file -a "path=~/openshift-auto-upi-workspace/${CLUSTER_NAME}/conf/manifests/ state=directory"
ansible helper -m copy -a "src=./docs/examples/ignition/filetranspiler/bootstrap/opt/openshift/manifests/cluster-scheduler-01-config.yml dest=~/openshift-auto-upi-workspace/${CLUSTER_NAME}/conf/manifests/
```
