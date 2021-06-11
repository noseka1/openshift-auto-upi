# Customizing Ignition Configs

## Using *filetranspiler* with *openshift-auto-upi*

### Installing *filetranspiler*

```
$ yum install podman
$ yum install git
```

```
$ git clone https://github.com/ashcrow/filetranspiler.git
$ cd filetranspiler
$ git checkout 1.1.2
```
Build the *filetranspiler* container image:

```
$ podman build --tag filetranspiler .
```

Verify that *filetranspiler* was installed properly:

```
$ podman run --rm -ti localhost/filetranspiler --version
```

### Usage

In your `openshift_cluster_hosts.yml` file you can specify which filetranspiler configuration will be applied to the ignition configs of the individual OpenShift hosts.

Sample filetranspiler customizations can be found [here](examples/ignition/filetranspiler/)

## Using *jsonpatch* to customize ignition configuration

In your `openshift_cluster_hosts.yml` file you can specify which jsonpatches will be applied to the ignition configs of the individual OpenShift hosts.

Sample jsonpatch customizations can be foud [here](examples/ignition/jsonpatch/)
