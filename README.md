# OpenShift Automated User-Provided Infrastructure

Preparing infrastructure for OpenShift installation by hand is a rather tedious job. In order to save the hard effort, *openshift-auto-upi* provides a set of Ansible scripts that automate the infrastructure creation.

*openshift-auto-upi* comes with roles to provision and configure:

* [DHCP Server](roles/dhcp_server)
* [DNS Server](roles/dns_server)
* [PXE Server](roles/pxe_server)
* [Web Server](roles/web_server)
* [Load Balancer](roles/loadbalancer)

Note that the infrastructure from the above list provisioned using *openshift-auto-upi* is NOT meant for production use. It is meant to be a temporary fill in for your missing production-grade infrastructure. It can also be used for learning purposes as it showcases a minimum working configuration. Using *openshift-auto-upi* to provisioning any of the infrastructure from the above list is optional.

*openshift-auto-upi* comes with roles to provision OpenShift cluster hosts on the following target platforms:

* [Bare Metal](roles/openshift_baremetal)
* [Libvirt](roles/openshift_libvirt)
* [vSphere](roles/openshift_vsphere)

# Deployment Overview

![Deployment Diagram](docs/openshift_auto_upi.svg "Deployment Diagram")

Note that in order to use DHCP or PXE server installed on the Builder host, the Builder host and all of the OpenShift nodes have to be provisioned on the same layer 2 network.

# Setting Up Builder Host

Supported operating systems:

* Red Hat Enterprise Linux 7
* Fedora release 31

## Configuring RHEL7

Enable additional Red Hat repositories:

```
$ yum-config-manager --enable rhel-7-server-optional-rpms
$ yum-config-manager --enable rhel-7-server-extras-rpms
```

Ansible >= 2.9 is required in order to run *openshift-auto-upi* scripts. Before installing Ansible on RHEL7, enable the Ansible version 2.9 repository:

```
$ yum-config-manager --enable rhel-7-server-ansible-2.9-rpms
```

If installing OpenShift on bare metal, the *python-pyghmi* library is required on Builder host. To install *python-pyghmi*:

```
$ yum-config-manager --enable rhel-7-server-openstack-14-rpms
$ yum install python-pyghmi
```

## Configuring Builder Host

```
$ yum install git
$ yum install ansible
```

```
$ git clone https://github.com/noseka1/openshift-auto-upi.git
$ cd openshift-auto-upi
```

Create custom *openshift_install_config.yml* configuration:

```
$ cp inventory/group_vars/all/openshift_install_config.yml.sample inventory/group_vars/all/openshift_install_config.yml
$ vi inventory/group_vars/all/openshift_install_config.yml
```

Create custom *openshift_cluster_hosts.yml* configuration:

```
$ cp inventory/group_vars/all/openshift_cluster_hosts.yml.sample inventory/group_vars/all/openshift_cluster_hosts.yml
$ vi inventory/group_vars/all/openshift_cluster_hosts.yml
```

Configure Builder host using Ansible:

```
$ ansible-playbook builder.yml
```

## Installing DHCP Server

Note that *dnsmasq.yml* configuration file is shared between the DHCP, DNS, and PXE servers.

```
$ cp inventory/group_vars/all/infra/dnsmasq.yml.sample inventory/group_vars/all/infra/dnsmasq.yml
$ vi inventory/group_vars/all/infra/dnsmasq.yml
```

```
$ cp inventory/group_vars/all/infra/dhcp_server.yml.sample inventory/group_vars/all/infra/dhcp_server.yml
$ vi inventory/group_vars/all/infra/dhcp_server.yml
```

Provision DHCP server on the Builder host using Ansible:

```
$ ansible-playbook dhcp_server.yml
```

## Installing DNS Server

Note that *dnsmasq.yml* configuration file is shared between the DHCP, DNS, and PXE servers.

```
$ cp inventory/group_vars/all/infra/dnsmasq.yml.sample inventory/group_vars/all/infra/dnsmasq.yml
$ vi inventory/group_vars/all/infra/dnsmasq.yml
```

```
$ cp inventory/group_vars/all/infra/dns_server.yml.sample inventory/group_vars/all/infra/dns_server.yml
$ vi inventory/group_vars/all/infra/dns_server.yml
```

Provision DNS server on the Builder host using Ansible:

```
$ ansible-playbook dns_server.yml
```

## Installing PXE Server

PXE server can be used for booting OpenShift nodes when installing on bare metal or libvirt target platform. Installation on vSphere doesn't use PXE boot at all.

Note that *dnsmasq.yml* configuration file is shared between the DHCP, DNS, and PXE servers.

```
$ cp inventory/group_vars/all/infra/dnsmasq.yml.sample inventory/group_vars/all/infra/dnsmasq.yml
$ vi inventory/group_vars/all/infra/dnsmasq.yml
```

Provision PXE server on the Builder host using Ansible:

```
$ ansible-playbook pxe_server.yml
```

## Installing Web Server

Provision Web server on the Builder host using Ansible:

```
$ ansible-playbook web_server.yml
```

## Installing Load Balancer

Provision load balancer on the Builder host using Ansible:

```
$ ansible-playbook loadbalancer.yml
```

# Installing OpenShift

## Installing OpenShift on Bare Metal

Kick off the OpenShift installation by issuing the command:

```
$ ansible-playbook openshift_baremetal.yml
```

## Installing OpenShift on Libvirt

Create custom *libvirt.yml* configuration:

```
$ cp inventory/group_vars/all/infra/libvirt.yml.sample inventory/group_vars/all/infra/libvirt.yml
$ vi inventory/group_vars/all/infra/libvirt.yml
```

Kick off the OpenShift installation by issuing the command:

```
$ ansible-playbook openshift_libvirt.yml
```

## Installing OpenShift on vSphere

Create custom *vsphere.yml* configuration:

```
$ cp inventory/group_vars/all/infra/vsphere.yml.sample inventory/group_vars/all/infra/vsphere.yml
$ vi inventory/group_vars/all/infra/vsphere.yml
```

Kick off the OpenShift installation by issuing the command:

```
$ ansible-playbook openshift_vsphere.yml
```
# openshift-auto-upi Development

## TODO List

* Support oVirt
* Check that quay.io is reachable (detect firewall issues)
* Add documentation on the vm boot order: disk and then network

## Futher Notes

IPMI can be tested using [VirtualBMC](https://github.com/openstack/virtualbmc)

