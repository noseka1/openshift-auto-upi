# Helper Host OS Specific Configuration

*openshift-auto-upi* assumes that SELinux is enabled and running either in Enforcing or Permissive mode. If you cannot enable SELinux you will have to manually correct the Ansible scripts to make them work.

## Configuring RHEL7

If you use RHEL7 on your Helper host, you will need to apply an additional configuration that is described in this section.

Enable additional Red Hat repositories:

```
$ subscription-manager repos --enable rhel-7-server-optional-rpms
$ subscription-manager repos --enable rhel-7-server-extras-rpms
```

Ansible >= 2.9 is required in order to run *openshift-auto-upi* scripts. Before installing Ansible on RHEL7, enable the Ansible version 2.9 repository:

```
$ subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
```

If installing OpenShift on bare metal, the *pyghmi* library is required on Helper host. This library implements the IPMI protocol which is used to control bare metal machines during the OpenShift installation. To enable a yum repository which contains the *python-pyghmi* rpm package:

```
$ subscription-manager repos --enable rhel-7-server-openstack-14-rpms
```

## Configuring RHEL8

If you use RHEL8 on your Helper host, you will need to apply an additional configuration that is described in this section.

Enable additional Red Hat repositories:

```
$ subscription-manager repos --enable ansible-2-for-rhel-8-x86_64-rpms
```

If installing OpenShift on bare metal, the *pyghmi* library is required on Helper host. This library implements the IPMI protocol which is used to control bare metal machines during the OpenShift installation. To enable a yum repository which contains the *python3-pyghmi* rpm package:

```
$ subscription-manager repos --enable openstack-15-for-rhel-8-x86_64-rpms
```

If installing OpenShift on vSphere, the *pyvmomi* library is required on Helper host. You can download the *python3-pyvmomi* rpm package from the [Red Hat Customer Portal](https://access.redhat.com).


## Configuring Fedora

No additional configuration is required for Fedora.

