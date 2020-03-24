# Using filetranspiler with openshift-auto-upi

Install *filetranspiler* with:

```
$ yum install podman
$ yum install git
```

```
$ git clone https://github.com/ashcrow/filetranspiler.git
$ cd filetranspiler
$ git checkout 1.1.1
```

```
$ podman build --tag filetranspiler .
```

```
$ podman run --rm -ti localhost/filetranspiler --version
```
