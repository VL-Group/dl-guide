# Title

## Install Docker

Install docker and change cgroup manager to systemd

```console
user@host:~$ # remove older dockers
user@host:~$ sudo apt-get remove docker docker-engine docker.io containerd runc
user@host:~$ # setup apt repos
user@host:~$ sudo apt-get update
user@host:~$ sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common
user@host:~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
user@host:~$ sudo apt-key fingerprint 0EBFCD88
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]

user@host:~$ # When using a cutting-edge lsb_release, change the $(lsb_release -cs) to
user@host:~$ # latest public lts i.e. bionic
user@host:~$ sudo add-apt-repository \
"deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
$(lsb_release -cs) \
stable"
user@host:~$ sudo apt-get update
user@host:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io
user@host:~$ # setup daemon
user@host:~$ cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
user@host:~$ sudo mkdir -p /etc/systemd/system/docker.service.d
user@host:~$ # restart docker
user@host:~$ sudo systemctl daemon-reload
user@host:~$ sudo systemctl restart docker
```

## Install NVIDIA docker 2

```console
user@host:~$ # Add the package repositories
user@host:~$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
user@host:~$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
user@host:~$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

user@host:~$ sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
user@host:~$ sudo systemctl restart docker
```

Check the docker runtine has been set correctly

```console
user@host:~$ cat /etc/docker/daemon.json
{
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```

## Deploy Kubernetes

### Install kubeadm

For each node in the cluster, you must:
* Turn off swap permanently
* Verify the MAC address and product_uuid are unique for every node
* Nodes are reachable on the network (add IP route(s) if necessary)
* Letting iptables see bridged traffic
* Check required ports

```console
user@host:~$ # turn off swap
user@host:~$ sudo swapoff -a
user@host:~$ # comment or remove the swap entry
user@host:~$ sudo vim /etc/fstab
user@host:~$ # remove the swap UUID
user@host:~$ sudo vim /etc/initramfs-tools/conf.d/resume
user@host:~$ sudo reboot
```

```console
user@host:~$ # check MAC in ifconfig
user@host:~$ ifconfig -a
user@host:~$ # check product uuid
user@host:~$ sudo cat /sys/class/dmi/id/product_uuid
```
```console
user@host:~$ # make sure br_netfilter is running
user@host:~$ sudo modprobe br_netfilter
user@host:~$ lsmod | grep br_netfilter
user@host:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
user@host:~$ sudo sysctl --system
```

Then, you should check required ports are not occupied with other programs, see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

#### Install kubeadm, kubelet and kubectl

```console
user@host:~$ # if can't access cloud.google.com, download it and add manually
user@host:~$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
user@host:~$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main
EOF
user@host:~$ sudo apt-get update
user@host:~$ sudo apt-get install -y kubelet kubeadm kubectl
user@host:~$ # prevent update
user@host:~$ sudo apt-mark hold kubelet kubeadm kubectl
user@host:~$ sudo apt list kubelet kubeadm kubectl
Listing... Done
kubeadm/kubernetes-xenial,now 1.18.2-00 amd64 [installed]
kubectl/kubernetes-xenial,now 1.18.2-00 amd64 [installed]
kubelet/kubernetes-xenial,now 1.18.2-00 amd64 [installed]
```

```console
user@host:~$ sudo systemctl daemon-reload
user@host:~$ sudo systemctl restart kubelet
```

* Configure Deployment

