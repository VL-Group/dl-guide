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
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
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
user@host:~$ mkdir -p /etc/systemd/system/docker.service.d
user@host:~$ # restart docker
user@host:~$ systemctl daemon-reload
user@host:~$ systemctl restart docker
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

* Enable MicroK8s GPU Addon

* Configure Deployment

