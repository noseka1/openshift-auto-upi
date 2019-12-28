Supported systems:

* Red Hat Enterprise Linux 7
* Fedora release 31

Requires Ansible >= 2.9

Before installing Ansible on RHEL7, enable the version 2.9 repository:

```
yum-config-manager --enable rhel-7-server-ansible-2.9-rpms
```

Sample commands:

```
ansible-playbook builder.yml
ansible-playbook dhcp_server.yml
ansible-playbook dns_server.yml
ansible-playbook dns_verify.yml
ansible-playbook web_server.yml
ansible-playbook loadbalancer.yml
ansible-playbook pxe_server.yml
ansible-playbook openshift_baremetal.yml
```
