# OpenShift Automated User-Provided Infrastructure

Preparing infrastructure for OpenShift installation by hand is a rather tedious job. In order to save the effort, *openshift-auto-upi* provides a set of Ansible scripts that automate the infrastructure creation.

*openshift-auto-upi* comes with Ansible roles to provision and configure:

* [DHCP Server](roles/dhcp_server)
* [DNS Server](roles/dns_server)
* [PXE Server](roles/pxe_server)
* [Web Server](roles/web_server)
* [Load Balancer](roles/loadbalancer)

Note that the infrastructure from the above list provisioned using *openshift-auto-upi* is NOT meant for production use. It is meant to be a temporary fill in for your missing production-grade infrastructure. It can also be used for learning purposes as it showcases a minimum working configuration. Using *openshift-auto-upi* to provision any of the infrastructure from the above list is optional.

*openshift-auto-upi* comes with Ansible roles to provision OpenShift cluster hosts on the following target platforms:

* [Bare Metal](roles/openshift_baremetal)
* [Libvirt](roles/openshift_libvirt)
* [vSphere](roles/openshift_vsphere)

# Deployment Overview

![Deployment Diagram](docs/openshift_auto_upi.svg "Deployment Diagram")

* **Builder Host** is a (virtual) machine that you must provide. It is a "helper" machine from which you will run *openshift-auto-upi* Ansible scripts and which may host part of your OpenShift infrastructure. Note that in order to achieve a minimum virtualized environment, **the Builder host and the Libvirt host may be the same machine**.
* **OpenShift Hosts** will be provisioned for you by *openshift-auto-upi* unless your target platform is bare metal.

Note that in order to use DHCP and/or PXE server installed on the Builder host, the Builder host and all of the OpenShift hosts have to be provisioned on the same layer 2 network. In the opposite case, it is sufficient to have a working IP route between the Builder host and the OpenShift hosts.

Here is a sample libvirt network configuration. It instructs libvirt to not provide DNS and DHCP servers for this network. Instead, DNS and DHCP servers for this network will be provided by *openshift-auto-upi*.

```xml
<network>
  <name>default</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='default' stp='on' delay='0'/>
  <dns enable='no'/>
  <ip address='192.168.150.1' netmask='255.255.255.0'>
  </ip>
</network>
```

# Dependency Diagram

The dependency diagram below depicts the dependencies between *openshift-auto-upi* Ansible playbooks. You want to execute Ansible playbooks in the dependency order. First, run the *builder* playbook at the top and then continue from top to bottom with the remaining playbooks. Following sections describe the installation process in more detail.

![Dependency Diagram](docs/openshift_auto_upi_dependency_graph.svg "Dependency Diagram")

# Setting Up Builder Host

There are two options to create a Builder Host:

* Create a Builder Host virtual machine. Recommended Builder Host machine size is 1 vCPU, 4GB RAM, and 10GB disk space. You have to install one of the supported operating systems on this machine.
* If you run one of the supported operating system on an existing machine, you can use this machine as your Builder Host.

Supported operating systems for the Builder Host are:

* Red Hat Enterprise Linux 7
* Red Hat Enterprise Linux 8
* Fedora release >= 31

Before continuing to the next section, follow the basic configuration steps described [here](docs/os_specific_config.md).

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

PXE server can be used for booting OpenShift hosts when installing on bare metal or libvirt target platform. Installation on vSphere doesn't use PXE boot at all.

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

## Configuring DNS Client

If you installed a DNS server on the Builder host, you may want to configure the Builder host to resolve OpenShift host names using this DNS server:

```
$ cp inventory/group_vars/all/infra/dns_client.yml.sample inventory/group_vars/all/infra/dns_client.yml
$ vi inventory/group_vars/all/infra/dns_client.yml
```

Configure the NetworkManager on the Builder host to forward OpenShift DNS queries to the local DNS server. Note that this playbook will issue `systemctl NetworkManager restart` to apply the configuration changes.

```
$ ansible-playbook dns_client.yml
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

* Implement Libvirt using [fw_cfg](https://github.com/coreos/coreos-assembler/blob/master/src/cmd-run)
* Support oVirt
* Check that quay.io is reachable (detect firewall issues)
* Add documentation on the vm boot order: disk and then network
* Support joining additional worker nodes after the cluster has been bootstrapped
* Container registry mirror, disconnected install (?)
* Shut down the bootstrap node and complete the installation process (?)

## Futher Notes

* IPMI can be tested on virtual machines using [VirtualBMC](https://github.com/openstack/virtualbmc)
* Check Ansible code using `ansible-lint *.yml`

