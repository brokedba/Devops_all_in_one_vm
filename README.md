# Devops_all_in_one_vm
This vagrant build is intended to provide a virtualbox vm where you can have most devops tools to play with and nested KVM configured.

✨ Please Read 👉🏼 [My blog to learn more](https://cloudthrill.ca/all-in-one-devops-vm).

 ----
![image](https://github.com/user-attachments/assets/9336afe4-a7b0-49a3-996f-92c002a28631)


 
In other words it's an ultimate Devops sandbox that the community can use to learn stuff without having to install anything. You'll just need to run `vagrant up` command to spin it.

**Note:** 
  - Host port forwarding is still having issues which means, contibutions are definitely welcome ;).
  - For now the oly build available is under ../OL7  but more EL8 builds will soon be added
 


# The current scope 
 The bundle includes the below services/devops tools :
- KVM
  - kcli (libvirt cli wrapper)
- Ansible AWX (Or replaced by Oracle linux aumtomation manager)
- Hashicorp
  - Terraform (KVM libvirt provider)
  - Packer
  - vault
- Docker
- Kubernetes single node (1.28)
  - Helm
  - Kubernetes Dashboard
  - k9s
  - kubectl autocompletion
  - kubescape
  - And more...
- Compliance as code
  - checkov
  - trivy
  - tfsec
  - terrascan
  - tfscan  
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
cd /path/to/Devops_all_in_one_vm/OL7
vagrant up

Rem Windows
cd \path\to\Devops_all_in_one_vm
vagrant up
```
# KVM
- Display current setup
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
# TERRAFORM (KVM)
```

[root@localhost]# wget  https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz
[root@localhost]# tar xvf terraform-provider-libvirt-**.tar.gz
```
- Add the plugin in a local registry
```
[root@localhost]# mkdir –p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
[root@localhost]# mv terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
```
- Add the below code block to the main.tf file to map libvirt references with the actual provider
```
[root@localhost projects]# cd /root/projects/terraform
[root@localhost]# vi libvirt.tf
...
terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}
... REST of the Config
```
- run :
  `terraform init && terraform plan`

  Read my full tutorial [here](http://www.brokedba.com/2021/12/terraform-for-dummies-part-5-terraform.html)
  
# KUBERNETES
- Create nginx deployment and list current K8 info
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
  - **Helm**
```
[root@localhost ~]# helm version --short
    v3.15.1+ge211f2a

[root@localhost ~]# helm repo add stable https://charts.helm.sh/stable
[root@localhost ~]# helm repo add bitnami https://charts.bitnami.com/bitnami
   "bitnami" has been added to your repositories
   "stable" has been added to your repositories

[root@localhost ~]# helm search repo list
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
bitnami/kube-state-metrics      4.2.3           2.12.0          kube-state-metrics is a simple service that lis...
bitnami/redis                   19.5.2          7.2.5           Redis(R) is an open source, advanced key-value ...
bitnami/redis-cluster           10.2.3          7.2.5           Redis(R) is an open source, scalable, distribut...
bitnami/valkey                  0.1.0           7.2.4           Valkey is an open source, advanced key-value st...
stable/redis                    10.5.7          5.0.7           DEPRECATED Open source, advanced key-value stor...
    
```
  - **Kubernetes Dashboard**
    ```
    kubectl proxy
    Starting to serve on 127.0.0.1:8001
    HTTP URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
    
    ```
 - **K9s**
![image](https://github.com/brokedba/Devops_all_in_one_vm/assets/29458929/539f42f4-2138-4da9-bbc2-0fb2acff69b0)

    
# AWX  
 in EL8, This will be replaced by OLAM (Oracle Fork that is rpm based). Thank you AWX maintainers for pooping the party with K8/docker complexity.
~Once the build is complete you should be able to access AWX using one of the following URLs. note: still in progress~
```
VERSION: 17.0.1   
Deployment framework: Docker
[root@localhost]# docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS              PORTS                                    NAMES
ad0415de0acd   ansible/awx:17.0.1   "/usr/bin/tini -- /u…"   About a minute ago   Up About a minute   8052/tcp                                awx_task
d323791a27cb   ansible/awx:17.0.1   "/usr/bin/tini -- /b…"   11 minutes ago       Up 11 minutes       0.0.0.0:80->8052/tcp, :::80->8052/tcp   awx_web
313ba9a22186   postgres:12          "docker-entrypoint.s…"   11 minutes ago       Up 11 minutes       5432/tcp                                awx_postgres
56385b68670d   redis                "docker-entrypoint.s…"   11 minutes ago       Up 11 minutes       6379/tcp                                awx_redis
```

* [http://localhost:8090](http://localhost:8090)
* [https://localhost:8443](https://localhost:8444)

Log in using the following credentials, assuming you've not changed them.

* Username: admin
* Password: password

![image](https://github.com/brokedba/Devops_all_in_one_vm/assets/29458929/b17662d7-9345-43a1-90bd-9dc4df5b007d)


# JENKINS
- Portal configuration
- Cli Help
```
[root@localhost ~]# wget http://localhost:8089/jnlpJars/jenkins-cli.jar
[root@localhost ~]# java -jar jenkins-cli.jar -s http://localhost:8089/ -webSocket -auth admin:password help
```
