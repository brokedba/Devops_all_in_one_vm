# Devops_all_in_one_vm
This vagrant build is intended to provide a virtualbox vm where you can have most devops tools and nested virtualization configured
This is a baby side project where Ièm aiming to hip a vagrant Devops # Ultimate VM for the community and which anyone can improve .
you'll just need to run vagrant up command to spin it .

The current scope for this side project includes autosetup of the below devops tools :
- kvm
- kcli (libvirt cli wrapper)
- ansible + AWX (maybe replaced by Oracle linux aumtomation managerin the future)
- Hashicorp
- Terraform (KVM libvirt provider)
- packaer/vault
- Docker
- Kubernetes single node
- helm
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
git clone https://github.com/brokedba/Devops_all_in_one.git
```

Navigate to the AWX build and issue the `vagrant up` command.

```
# Linux
cd /path/to/vagrant/awx
vagrant up

Rem Windows
cd \path\to\vagrant\awx
vagrant up
```

Once the build is complete you should be able to access AWX using one of the following URLs.

* [http://localhost:8080](http://localhost:8080)
* [https://localhost:8443](https://localhost:8443)

Log in using the following credentials, assuming you've not changed them.

* Username: admin
* Password: password

