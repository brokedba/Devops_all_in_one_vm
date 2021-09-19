echo "******************************************************************************"    
echo "Install tmate (collaboration tool) " `date`                                                
echo "******************************************************************************" 

curl -L https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz | tar Jxvf - ; mv tmate*/tmate /usr/bin

echo "******************************************************************************"    
echo "Install KMV and Kcli" `date`                                                
echo "******************************************************************************"    

yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer virt-top libguestfs-tools-c
/usr/libexec/qemu-kvm --version
systemctl enable --now libvirtd
systemctl status libvirtd |grep Active
mkdir /u01/guest_images
sudo setfacl -m u:$(id -un):rwx /u01/guest_images
pip2 uninstall -y urllib3
yum reinstall -y python-requests
yum install -y fuse 
modprobe fuse
virt-host-validate

echo
echo +++++ "Install Kcli" `date` +++++++ 
echo
curl https://raw.githubusercontent.com/karmab/kcli/master/install.sh | sh 
mv  /root/.kcli/profile.yml  /root/.kcli/profile.yml.old
cp /vagrant/scripts/profiles.yml  /root/.kcli/
kcli create host kvm -H 127.0.0.1 local
cp /root/.kcli/config.yml /root/.kcli/config.yml.old
sed -i '4 i \ \ virttype: qemu' /root/.kcli/config.yml
echo " adapt kcli alias with the default pool path /u01/guest_image "
cp /root/.bashrc /root/bashrc.old
sed -i '13d' /root/.bashrc
echo "alias kcli='docker run --net host -it --rm --security-opt label=disable -v /root/.kcli:/root/.kcli -v /root/.ssh:/root/.ssh -v /u01/guest_images:/u01/guest_images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir quay.io/karmab/kcli'" >> /root/.bashrc
echo "******************************************************************************"
echo "Install terraform." `date`
echo "******************************************************************************"
<<OLDINSTALL
curl -O https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip -d /usr/bin/
OLDINSTALL
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install -y terraform
terraform -version 
cd /root/
terraform init
cd /root/.terraform.d
mkdir plugins
echo
echo " import terraform libvirt provider for CentOS 7 / Fedora "
echo
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz
tar xvf terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz
mv terraform-provider-libvirt /root/.terraform.d/plugins/
echo
echo " Using Terraform KVM Provider"
echo
mkdir -p /root/projects/terraform
cp /vagrant/scripts/libvirt.tf /root/projects/terraform/ 
echo " import terraformer providers for CentOS 7 / Fedora "
echo
export PROVIDER={all,google,aws,kubernetes,azure}
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64
chmod +x terraformer-${PROVIDER}-linux-amd64
sudo mv terraformer-${PROVIDER}-linux-amd64 /usr/local/bin/terraformer


echo "******************************************************************************"
echo "Install Packer an vault." `date`
echo "******************************************************************************"
  
 sudo yum -y install packer
 sudo yum -y install vault


  <<RHEL_REPO
  curl -O https://releases.hashicorp.com/packer/1.5.5/packer_1.5.5_linux_amd64.zip
  curl -O https://releases.hashicorp.com/packer/1.5.5/packer_1.5.5_SHA256SUMS
  curl -O https://releases.hashicorp.com/packer/1.5.5/packer_1.5.5_SHA256SUMS.sig
  gpg --recv-keys 51852D87348FFC4C
  gpg --verify packer_1.5.5_SHA256SUMS.sig packer_1.5.5_SHA256SUMS
  sha256sum -c packer_1.5.5_SHA256SUMS 2>/dev/null | grep OK
  echo " named the Packer binary packer.io to avoid confusion with another redhat builtin program also called packer "
  unzip packer*.zip ; rm -f packer*.zip
  chmod +x packer
  mv packer /usr/bin/packer.io
RHEL_REPO
packer  -v
packer -autocomplete-install

echo "******************************************************************************"
echo "Install Jenkins." `date`
echo "******************************************************************************"
  
   wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
   rpm –import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
   yum install jenkins –y


echo "******************************************************************************"
echo "Install Single node kubernetes." `date`
echo "******************************************************************************"

swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
# sudo sed -i '/swap/d' /etc/fstab

echo " Letting iptables see bridged traffic "
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo " Adding the kubernetes repo "
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

echo " install kube binaries kubelet, kubectl and kubeadm"

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

echo " Start the cluster using calico network service (L3 layer routing)"
echo "... This will take few minutes...Make not of the kubeadm join message for the future node addition"
kubeadm init --pod-network-cidr=192.168.0.0/16
echo " Post install setup"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 
echo "--- Calico svc install"
kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
echo 
echo "--- Enable POD run on the Master Node (single cluster) ---"
kubectl taint nodes --all node-role.kubernetes.io/master-
echo 
echo "Install the kubernetes Dashboard "
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
# continue the configuration by following the link https://medium.com/@srpillai/single-node-kubernetes-on-centos-c8c3507e3e65

echo "******************************************************************************"
echo "Install helm." `date`
echo "******************************************************************************"
 
 curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
 chmod 700 get_helm.sh
 ./get_helm.sh