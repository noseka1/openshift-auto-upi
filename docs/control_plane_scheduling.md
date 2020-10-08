# Making control-plane unschedulable

The control plane, or master, machines are set schedulable by default and application pods run on the master nodes and there're two options to prevent pods from being scheduled on the control plane machines during the installation, so you can choose either of them. See [Configuring master nodes as schedulable](https://docs.openshift.com/container-platform/4.5/nodes/nodes/nodes-nodes-working.html#nodes-nodes-working-master-schedulable_nodes-nodes-working), if you want to get it done after the installation.

* [Modify the <installation_directory>/manifests/cluster-scheduler-02-config.yml Kubernetes manifest file](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-generate-k8s-manifest-ignition_installing-bare-metal) after generating the Kubernetes manifests.

You simply add the following task in the `roles/openshift_common/tasks/generate_ignition_tasks.yml` file and it needs be between `Create Kubernetes manifests` and `Create ignition configs` tasks exist.

```
- name: Create Kubernetes manifests # noqa 301
<...>
- name: Mark control plane as unscheduleable
  lineinfile:
    path: '{{ openshift_install_dir }}/manifests/cluster-scheduler-02-config.yml'
    regexp: '^(\s*mastersSchedulable:)'
    line: '\1 false'
    backrefs: True

- name: Create ignition configs # noqa 301
```

* Place the scheduler policy file either before or after generating the Kubernetes manifests.

To place the scheduler policy file, create tha manifests directory and place the policy file before running `openshift_baremetal.yml` or `openshift_libvirt_pxe.yml`.
```
export CLUSTER_NAME=$(awk '/name: / {print $2}' ~/openshift-auto-upi/inventory/group_vars/all/openshift_install_config.yml)
ansible helper -m file -a "path=~./files/ignition/filetranspiler/bootstrap/opt/openshift/manifests state=directory"
ansible helper -m copy -a "src=./docs/examples/ignition/filetranspiler/bootstrap/opt/openshift/manifests/cluster-scheduler-01-config.yml dest=./files/ignition/filetranspiler/bootstrap/opt/openshift/manifests/cluster-scheduler-01-config.yml"
```

In addition, add the `ignition_transform` variable in the bootstrap section to `the openshift_cluster_hosts.yml` file to enable the ignition modification for the boostrap node:
```
openshift_cluster_hosts:
  - hostname: bootstrap
    <...>
    ignition_transform:
      filetranspiler_roots:
        - files/ignition/filetranspiler/bootstrap
  - hostname: master1
```
