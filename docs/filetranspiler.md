# Using *filetranspiler* with *openshift-auto-upi*

## Installing *filetranspiler*

```
$ yum install podman
$ yum install git
```

```
$ git clone https://github.com/ashcrow/filetranspiler.git
$ cd filetranspiler
$ git checkout 1.1.1
```
Build the *filetranspiler* container image:

```
$ podman build --tag filetranspiler .
```

Verify that *filetranspiler* was installed properly:

```
$ podman run --rm -ti localhost/filetranspiler --version
```
