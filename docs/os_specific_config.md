# Helper Host OS Specific Configuration

*openshift-auto-upi* assumes that SELinux is enabled and running on your Helper host. Both Enforcing and Permissive SELinux modes are supported. If you cannot enable SELinux on your Helper host, you will have to manually modify the Ansible scripts to correct SELinux related errors as you encounter them.

Note that at this time (April 2020) I could not find oVirt Engine SDK packages for Python 3 for RHEL8 and Fedora. If you are installing OpenShift on oVirt, I recommend to use RHEL7 on your Helper host as this is supported by the *openshift-auto-upi* scripts. You can make oVirt work on Fedora and RHEL8 by installing oVirt Engine SDK for Python 3 using pip:
```
$ pip install ovirt-engine-sdk-python
```
You will need to modify *openshift-auto-upi* scripts and remove the installation of the oVirt Engine SDK rpm package.

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

If installing OpenShift on oVirt (RHV), the Python SDK for oVirt Engine API is required on Helper host. To enable a yum repository which contains the *python-ovirt-engine-sdk4* rpm package:

```
$ subscription-manager repos --enable rhel-7-server-rh-common-rpms
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
