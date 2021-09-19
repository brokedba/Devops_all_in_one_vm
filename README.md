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

Navigate to the AWX build and issue the `vagrant up` command.

```
# Linux
cd /path/to/Devops_all_in_one_vm
vagrant up

Rem Windows
cd \path\to\Devops_all_in_one_vm
vagrant up
```

Once the build is complete you should be able to access AWX using one of the following URLs.

* [http://localhost:8080](http://localhost:8080)
* [https://localhost:8443](https://localhost:8443)

Log in using the following credentials, assuming you've not changed them.

* Username: admin
* Password: password

