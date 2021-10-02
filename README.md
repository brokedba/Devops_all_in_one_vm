# Devops_all_in_one_vm
This vagrant build is intended to provide a virtualbox vm where you can have most devops tools to play with and nested KVM configured.
![image](https://user-images.githubusercontent.com/29458929/133898614-ab96bba8-21e1-4f04-9b78-42f0242b71ec.png)

 
In other words it's an ultimate Devops sandbox that the community can use to learn stuff without having to install anything. You'll just need to run `vagrant up` command to spin it.
- Note: Contibution is welcome too.
 


# The current scope 
 The bundle includes the below services/devops tools :
- kvm
  - kcli (libvirt cli wrapper)
- Ansible AWX (Or replaced by Oracle linux aumtomation manager)
- Hashicorp
  - Terraform (KVM libvirt provider)
  - Packer/vault
- Docker
- Kubernetes single node
  - Helm
  - Kubernetes Dashboard
- Jenkins
- Cloud shell CLI (OCI/AWS/AZ/GCP) install only
- Other: tmate,bind-utils etc


## Required Software

* [Vagrant](https://www.vagrantup.com/downloads.html)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Using It

Clone or [Download](https://github.com/brokedba/devops_all_in_one/archive/master.zip) the repository.

```
git clone https://github.com/brokedba/Devops_all_in_one_vm.git
```

Navigate to the build directory and issue the `vagrant up` command.

```
# Linux
cd /path/to/Devops_all_in_one_vm
vagrant up

Rem Windows
cd \path\to\Devops_all_in_one_vm
vagrant up
```
# KVM
- display current setup
```
[root@localhost ~]# kcli list pool
+---------+-------------------+
| Pool    |        Path       |
+---------+-------------------+
| default | /u01/guest_images |
+---------+-------------------+
[root@localhost ~]# kcli list network
Listing Networks...
+---------+--------+------------------+------+---------+------+
| Network |  Type  |       Cidr       | Dhcp |  Domain | Mode |
+---------+--------+------------------+------+---------+------+
| default | routed | 192.168.122.0/24 | True | default | nat  |
+---------+--------+------------------+------+---------+------+
```

# KUBERNETES
- create nginx deployment and list current K8 info
```
[root@localhost ~]# kubectl -n kube-system get cm kubeadm-config -o yaml
[root@localhost ~]# kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
[root@localhost ~]# kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE
my-nginx-66b6c48dd5-25qr2   1/1     Running   0          12m
my-nginx-66b6c48dd5-9bz4h   1/1     Running   0          12m
my-nginx-66b6c48dd5-s4hrn   1/1     Running   0          12m

[root@localhost ~]# kubectl get services --sort-by=.metadata.name
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP      10.96.0.1       <none>        443/TCP        72m
my-nginx-svc   LoadBalancer   10.109.205.27   <pending>     80:31302/TCP   19m

[root@localhost ~]# kubectl get deploy -o wide
NAME       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
my-nginx   3/3     3            3           21m   nginx        nginx:1.14.2   app=nginx
[root@localhost ~]# kubectl get namespace
[root@localhost ~]# kubectl get events --sort-by=.metadata.creationTimestamp
```
# AWX
Once the build is complete you should be able to access AWX using one of the following URLs. note: still in progress

* [http://localhost:8080](http://localhost:8080)
* [https://localhost:8443](https://localhost:8443)

Log in using the following credentials, assuming you've not changed them.

* Username: admin
* Password: password

