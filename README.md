# OpenShift Automated User-Provided Infrastructure

Preparing infrastructure for OpenShift 4 installation by hand is a rather tedious job. In order to save the effort, *openshift-auto-upi* provides a set of Ansible scripts that automate the infrastructure creation.

*openshift-auto-upi* is a separate tool, and is not in any way part of the OpenShift product. It enhances the *openshift-installer* by including automation for the following:

*openshift-auto-upi* comes with Ansible roles to provision OpenShift cluster hosts on the following target platforms:

* [Bare Metal](roles/openshift_baremetal)
* [Libvirt](docs/openshift_libvirt.md)
* [oVirt (RHEV)](roles/openshift_ovirt)
* [vSphere](roles/openshift_vsphere)

*openshift-auto-upi* comes with Ansible roles to provision and configure:

* [DHCP Server](roles/dhcp_server)
* [DNS Server](roles/dns_server)
* [PXE Server](roles/pxe_server)
* [Web Server](roles/web_server)
* [Load Balancer](roles/loadbalancer)
* [Mirror Registry](roles/mirror_registry)

Note that the infrastructure from the above list provisioned using *openshift-auto-upi* is NOT meant for production use. It is meant to be a temporary fill in for your missing production-grade infrastructure. Using *openshift-auto-upi* to provision any of the infrastructure from the above list is optional.

# Deployment Overview

![Deployment Diagram](docs/openshift_auto_upi.svg "Deployment Diagram")

* **Helper host** is a (virtual) machine that you must provide. It is a helper machine from which you will run *openshift-auto-upi* Ansible scripts. Any provisioned infrastructure (DHCP, DNS server, ...) will also be installed on the Helper host by default.
  * Helper host requires access to the Internet.
  * It is stronly discouraged to use *openshift-auto-upi* to provision infrastructure components on a bastion host. Services provisioned by *openshift-auto-upi* are not meant to be exposed to the public Internet.
  * If your goal is to deploy OpenShift on your laptop, you can run the *openshift-auto-upi* directly on your laptop and use the local Libvirt as your target platform.
* **OpenShift hosts** will be provisioned for you by *openshift-auto-upi* unless your target platform is bare metal.

## Networking

*openshift-auto-upi* assumes that OpenShift hosts are assigned fixed IP addresses. This is accomplished by pairing the hosts MAC addresses with IP addresses in the DHCP server configuration. DHCP server then always assigns the same IP address to a specific host.

Note that in order to use DHCP and/or PXE server installed on the Helper host, the Helper host and all of the OpenShift hosts have to be provisioned on the same layer 2 network. In the opposite case, it is sufficient to have a working IP route between the Helper host and the OpenShift hosts.

If the DNS server is managed by *openshift-auto-upi*, a DNS name will be created for each OpenShift host. These DNS names follow the scheme:
```
<hostname>.<cluster_name>.<base_domain>
```
Note that these names are created only for your convenience. *openshift-auto-upi* doesn't rely on their existence as they are not required for installing OpenShift.

## Deployment Playbooks

The table below depicts the *openshift-auto-upi* Ansible playbooks that you need to execute in order to deploy OpenShift on select target platform. You want to execute the Ansible playbooks in the order from top to bottom. Following sections describe the installation process in more detail.

| | Bare metal | Libvirt FwCfg | Libvirt PXE | oVirt | vSphere |
|-|:-:|:-:|:-:|:-:|:-:|
| **mirror_registry** | optional | optional | optional | optional | optional |
| **clients** | required | required | required | required | required |
| **dhcp_server** | optional | optional | optional | optional | optional | optional |
| **dns_server** | optional | optional | optional | optional | optional | optional |
| **pxe_server** | required | - | required | - | - | - |
| **web_server** | required | - | required | - | - | - |
| **loadbalancer** | optional | optional | optional | optional | optional |
| **dns_client** | optional | optional | optional | optional | optional |

# Setting Up Helper Host

There are two options to create a Helper host:

* Create a Helper host virtual machine. Minimum recommended Helper host machine size is 1 vCPU, 4 GB RAM, and 10 GB disk space. You have to install one of the supported operating systems on this machine.
* If you run one of the supported operating system on an existing machine, you can use that machine as your Helper host.

Supported operating systems for the Helper host are:

* Red Hat Enterprise Linux 7
* Red Hat Enterprise Linux 8
* Fedora release >= 31

Before continuing with the next steps, make sure that you applied the [OS-specific configuration instructions](docs/os_specific_config.md).

```
$ yum install git
$ yum install ansible
```
Clone the *openshift-auto-upi* repo to your Helper host and check out a tagged release. I recommend that you use a tagged release which receives more testing than master:

```
$ git clone https://github.com/noseka1/openshift-auto-upi.git
$ git checkout <release_tag>
$ cd openshift-auto-upi
```

## Creating Mirror Registry

If you are installing OpenShift in a restricted network, you will need to create a local mirror registry. This registry will contain all OpenShift container images required for the installation. *openshift-auto-upi* automates the creation of the mirror registry by implementing the steps described in the [Creating a mirror registry](https://docs.openshift.com/container-platform/latest/installing/install_config/installing-restricted-networks-preparations.html). To set up a mirror registry:

```
$ cp inventory/group_vars/all/infra/mirror_registry.yml.sample \
    inventory/group_vars/all/infra/mirror_registry.yml
$ vi inventory/group_vars/all/infra/mirror_registry.yml
```

```
$ ansible-playbook mirror_registry.yml
```

## Preparing for OpenShift Installation

Create custom *openshift_install_config.yml* configuration:

```
$ cp inventory/group_vars/all/openshift_install_config.yml.sample \
    inventory/group_vars/all/openshift_install_config.yml
$ vi inventory/group_vars/all/openshift_install_config.yml
```

Create custom *openshift_cluster_hosts.yml* configuration:

```
$ cp inventory/group_vars/all/openshift_cluster_hosts.yml.sample \
    inventory/group_vars/all/openshift_cluster_hosts.yml
$ vi inventory/group_vars/all/openshift_cluster_hosts.yml
```

Download OpenShift clients using Ansible:

```
$ ansible-playbook clients.yml
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

Provision DHCP server on the Helper host using Ansible:

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

Provision DNS server on the Helper host using Ansible:

```
$ ansible-playbook dns_server.yml
```

## Installing PXE Server

PXE server can be used for booting OpenShift hosts when installing on bare metal or libvirt target platform. Installation on vSphere doesn't use PXE boot at all.

Note that *dnsmasq.yml* configuration file is shared between the DHCP, DNS, and PXE servers.

```
$ cp inventory/group_vars/all/infra/dnsmasq.yml.sample inventory/group_vars/all/infra/dnsmasq.yml
$ vi inventory/group_vars/all/infra/dnsmasq.yml
```

Provision PXE server on the Helper host using Ansible:

```
$ ansible-playbook pxe_server.yml
```

## Installing Web Server

Web server is used to host installation artifacts such as ignition files and machine images. You can provision a Web server on the Helper host using Ansible:

```
$ ansible-playbook web_server.yml
```

## Installing Load Balancer

Provision load balancer on the Helper host using Ansible:

```
$ ansible-playbook loadbalancer.yml
```

## Configuring DNS Client

If you used *openshift-auto-upi* to deploy a DNS server, you may want to configure the Helper host to resolve OpenShift host names using this DNS server:

```
$ cp inventory/group_vars/all/infra/dns_client.yml.sample inventory/group_vars/all/infra/dns_client.yml
$ vi inventory/group_vars/all/infra/dns_client.yml
```

Configure the NetworkManager on the Helper host to forward OpenShift DNS queries to the local DNS server. Note that this playbook will issue `systemctl NetworkManager restart` to apply the configuration changes.

```
$ ansible-playbook dns_client.yml
```

# Installing OpenShift

## Installing OpenShift on Bare Metal

Create your `install-config.yaml` file:

```
$ cp files/common/install-config.yaml.sample files/common/install-config.yaml
$ vi files/common/install-config.yaml
```

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

Create your `install-config.yaml` file:

```
$ cp files/common/install-config.yaml.sample files/common/install-config.yaml
$ vi files/common/install-config.yaml
```

In order to install OpenShift using the Libvirt FwCfg method, kick off the installation by issuing the command:

```
$ ansible-playbook openshift_libvirt_fwcfg.yml
```

Alternatively, in order to install OpenShift using the Libvirt PXE method, kick off the installation by issuing the command:

```
$ ansible-playbook openshift_libvirt_pxe.yml
```


## Installing OpenShift on oVirt

Create custom *ovirt.yml* configuration:

```
$ cp inventory/group_vars/all/infra/ovirt.yml.sample inventory/group_vars/all/infra/ovirt.yml
$ vi inventory/group_vars/all/infra/ovirt.yml
```

Create your `install-config.yaml` file:

```
$ cp files/common/install-config.yaml.sample files/common/install-config.yaml
$ vi files/common/install-config.yaml
```

Kick off the OpenShift installation by issuing the command:

```
$ ansible-playbook openshift_ovirt.yml
```

## Installing OpenShift on vSphere

Create custom *vsphere.yml* configuration:

```
$ cp inventory/group_vars/all/infra/vsphere.yml.sample inventory/group_vars/all/infra/vsphere.yml
$ vi inventory/group_vars/all/infra/vsphere.yml
```

Create your `install-config.yaml` file:

```
$ cp files/common/install-config.yaml.sample files/common/install-config.yaml
$ vi files/common/install-config.yaml
```

Kick off the OpenShift installation by issuing the command:

```
$ ansible-playbook openshift_vsphere.yml
```
# Adding Cluster Nodes

Add the new hosts to the list of cluster hosts:

```
$ vi inventory/group_vars/all/openshift_cluster_hosts.yml
```

If you are adding infra hosts and you use the load balancer managed by openshift-auto-upi, refresh the load balancer configuration by re-running the Ansible playbook:

```
$ ansible-playbook loadbalancer.yml
```

Re-run the platform-specific playbook to install the new cluster hosts:

```
$ ansible-playbook openshift_<baremetal|libvirt_fwcfg|libvirt_pxe|ovirt|vsphere>.yml
```

To allow the new nodes to join the cluster, you may need to sign their CSRs:

```
$ oc get csr
$ oc adm certificate approve <name>
```

# openshift-auto-upi Development

## TODO List

Refer to the [openshift-auto-upi project board](https://github.com/noseka1/openshift-auto-upi/projects/3)

## Development Notes

* IPMI can be tested on virtual machines using [VirtualBMC](https://github.com/openstack/virtualbmc)
* Check Ansible code using `ansible-lint *.yml`

# References

Projects similar to *openshift-auto-upi*:
* [ocp4-upi-helpernode](https://github.com/christianh814/ocp4-upi-helpernode)
* [ocp4-vsphere-upi-automation](https://github.com/vchintal/ocp4-vsphere-upi-automation)
* [openshift4-rhv-upi](https://github.com/sa-ne/openshift4-rhv-upi)
* [openshift4-vmware-upi](https://github.com/sa-ne/openshift4-vmware-upi)
