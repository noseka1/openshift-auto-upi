# Installing OpenShift on Libvirt

## Choosing Installation Method

There are two installation methods available for Libvirt: FwCfg and PXE:

1. **FwCfg**. This installation method uses OpenShift QEMU images. The ignition configuration is passed to the virtual machines using [QEMU Firmware Configuration Device](https://github.com/qemu/qemu/blob/master/docs/specs/fw_cfg.txt). Virtual machines are created from a shared disk image template which allows for better hardware utilization than what can be accomplished with the PXE installation method. <br/>
:exclamation: QEMU Firmware Configuration Device feature is not available on RHEL7. If you are installing OpenShift on a RHEL7 based hypervisor, you must use the PXE installation method.

2. **PXE**. This installation method utilizes the bare metal installation procedure in order to install OpenShift on virtual machines. This method is more complex and less resource efficient than the FwCfg installation method, however, it works on RHEL7. It can also be used for testing of bare metal installations when bare metal instances are not available.

## Configuring Libvirt

Create a default storage pool in libvirt if it doesn't exist. Sample configuration:
```xml
<!-- default-pool.xml -->
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
```

```
$ virsh pool-define default-pool.xml
```

```
$ virsh pool-start default
```

```
$ virsh pool-autostart default
```

Unless you want to reuse one of the existing networks, I recommend that you create a separate network for OpenShift. The following sample network configuration instructs libvirt to not provide DNS and DHCP servers for this network. Instead, DNS and DHCP servers for this network will be provided by *openshift-auto-upi*.

```xml
<!-- openshift-network.xml -->
<network>
  <name>openshift</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='openshift' stp='on' delay='0'/>
  <dns enable='no'/>
  <ip address='192.168.150.1' netmask='255.255.255.0'>
  </ip>
</network>
```

```
$ virsh net-define openshift-network.xml
```

```
$ virsh net-start openshift
```

```
$ virsh net-autostart openshift
```

## Enabling remote connection

To configure management access to libvirt via SSH to separate the helper host from the KVM host, you need to set the `libvirt.libvirt_connection_uri` variable in your `inventory/group_vars/all/infra/libvirt.yml` file so that the helper host is able to connect to the libvirt daemon management socket on the KVM host via SSH to create virtual machines.

```
libvirt:
  libvirt_connection_uri: 'qemu+ssh://root@192.168.150.1/system'
```

But it prompts for the root password after you issue `ansible-playbook openshift_libvirt_[fwcfg|pxe].yml` command and you need to type the password tens of times depending on the number of the OpenShift hosts during the installation. This is because you are trying to connect to libvirt as root user.

To avoid typing the password over and over again, you need to set the public key on the KVM host as root user and the secret key on the helper ost as root user.
Assuming you are in the helper host and the secret and the public key are on the host, you can arrange the key files by issuing the command:

```
ssh-copy-id -i ~/.ssh/id_rsa root@<KVM_HOST>
sudo cp ~/.ssh/id_rsa /root/.ssh/id_rsa
```
