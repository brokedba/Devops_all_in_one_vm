echo "******************************************************************************"    
echo "Install tmate (collaboration tool) " `date`                                                
echo "******************************************************************************" 

curl -L https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz | tar Jxvf - ; mv tmate*/tmate /usr/bin
yum -q -y install jq
echo "******************************************************************************"    
echo "Install KMV and Kcli" `date`                                                
echo "******************************************************************************"    

yum install -q -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer virt-top libguestfs-tools-c fuse
/usr/libexec/qemu-kvm --version
systemctl enable --now libvirtd
systemctl status libvirtd |grep Active
mkdir /u01/guest_images
sudo setfacl -m u:$(id -un):rwx /u01/guest_images
pip3 uninstall -y urllib3
yum reinstall -q  -y python-requests
modprobe fuse
echo "fuse" > /etc/modules-load.d/fuse.conf
yum install -q  -y http://mirror.centos.org/centos/7/os/x86_64/Packages/OVMF-20180508-6.gitee3198e672e2.el7.noarch.rpm  #UEFI firmware
virt-host-validate
virsh pool-define-as default dir - - - - "/u01/guest_images"
virsh pool-build default
virsh pool-start default 
virsh pool-autostart default
echo
echo +++++ "Install Kcli" `date` +++++++ 
echo
curl https://raw.githubusercontent.com/karmab/kcli/master/install.sh | sh 
#mv  /root/.kcli/profiles.yml  /root/.kcli/profiles.yml.old
alias kcli='docker run --net host -i --rm --security-opt label=disable -v /root/.kcli:/root/.kcli -v /root/.ssh:/root/.ssh -v /u01/guest_images:/u01/guest_images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir quay.io/karmab/kcli'
echo "==== create kcli configuration"
kcli create host kvm -H 127.0.0.1 local
sed -i '4 i \ \ virttype: qemu' /root/.kcli/config.yml
echo " adapt kcli alias with the default pool path /u01/guest_image "
cp /root/.bashrc /root/bashrc.old
sed -i '13d' /root/.bashrc
echo "alias kcli='docker run --net host -it --rm --security-opt label=disable -v /root/.kcli:/root/.kcli -v /root/.ssh:/root/.ssh -v /u01/guest_images:/u01/guest_images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir quay.io/karmab/kcli'" >> /root/.bashrc
source /root/.bashrc
cp /vagrant/scripts/profiles.yml  /root/.kcli/

echo "******************************************************************************"
echo "Install terraform." `date`
echo "******************************************************************************"
<<OLDINSTALL
curl -O https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip -d /usr/bin/
OLDINSTALL
#yum install -q -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
majversion=$(lsb_release -rs | cut -f1 -d.)
sudo sed -i 's/$releasever/'"$majversion"'/g' /etc/yum.repos.d/hashicorp.repo
sudo rpm --import https://rpm.releases.hashicorp.com/gpg
yum install -q -y terraform
terraform -version 
cd /root/
terraform init
cd /root/.terraform.d
mkdir plugins
echo
echo " import terraform libvirt provider for CentOS 7 / Fedora "
echo
wget -q https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64.tar.gz
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
echo "Install Packer and vault." `date`
echo "******************************************************************************"
  
 sudo yum -q -y install packer vault

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
echo "Install Jenkins." `date` # https://pkg.jenkins.io/redhat-stable/
echo "******************************************************************************"
  
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#  yum install java-11-openjdk-devel old 
yum install -y jenkins
# config/etc/sysconfig/jenkins
sed -i 's/JENKINS_PORT=8080/JENKINS_PORT=8089/g'  /usr/lib/systemd/system/jenkins.service
# sed -i 's/#\(Environment="JAVA_HOME=.*"\)/\1/; s/\(Environment="JAVA_HOME=\).*/\1\/usr/lib/jvm/java-11-openjdk"/' /usr/lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
systemctl restart jenkins 
systemctl enable jenkins

echo "******************************************************************************"
echo "Install Single node kubernetes." `date`
echo "******************************************************************************"

swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
# sudo sed -i '/swap/d' /etc/fstab

echo " === Letting iptables see bridged traffic "
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
echo
echo " ===Adding the kubernetes repo "

#<<OLDINSTALL
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
#yum update -y
yum makecache

echo " === install kube binaries kubelet, kubectl and kubeadm"
yum install -q  -y kubelet kubeadm kubectl iproute-tc --disableexcludes=kubernetes
# or sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock --kubernetes-version v1.28.0
systemctl enable --now kubelet
echo " === initiate a cluster using kubeadm init"
echo "... This will take few minutes...Make not of the kubeadm join message for the future node addition"
#### create containerd config to fix Kubelet Container Runtime Interface (CRI) issue https://github.com/containerd/containerd/issues/8139
#### [ERROR CRI]: container runtime is not running: CRI v1 runtime API is not implemented for endpoint "unix:///var/run/containerd/containerd.sock
### this is not encountered on k8 v1.8 so we keep that version for now 
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo sed -i 's/pause:3.6/pause:3.9/g' /etc/containerd/config.toml 
sudo systemctl restart containerd
echo " execute kubeadm init"
# if in doubt run: <kubeadm reset> for a clean reset of the control-plan 
#  sudo kubeadm init   --pod-network-cidr=10.244.0.0/16   --upload-certs --kubernetes-version=v1.28.0  --control-plane-endpoint=$(hostname) --ignore-preflight-errors=all  --cri-socket unix:///run/containerd/containerd.sock
kubeadm init --pod-network-cidr=192.168.0.0/16 

# --ignore-preflight-errors=SystemVerification to ignore btrfs fatal error if defined
echo " Post install setup"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo" set KUBECONFIG for root user"
echo "KUBECONFIG=/etc/kubernetes/admin.conf; export KUBECONFIG" >> /root/.bashrc
echo 
 systemctl daemon-reload
echo "--- Enable POD run on the Master Node (single cluster) ---"
# master has been replced by control-pane node-role.kubernetes.io/master-
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 

echo " ==== configure a cluster with calico network service (L3 layer routing)"
# tigera operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
# calico crd : makes sure IpPools cidr is the same as the one on kubeadm init --pod-network-cidr
#i.e : 192.168.0.0/16
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
echo 
echo 
kubectl get nodes -o wide
echo "==== Install the kubernetes Dashboard "
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
# Starting from the release v7 for the Helm chart and v3 for the Kubernetes Dashboard, underlying architecture has changed, and it requires a clean installation.
# Please remove previous installation first.
# # Add kubernetes-dashboard repository
# helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
# helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
# continue the configuration by following the link https://medium.com/@srpillai/single-node-kubernetes-on-centos-c8c3507e3e65

echo "******************************************************************************"
echo "Install helm." `date`
echo "******************************************************************************"
 
 curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
 chmod 700 get_helm.sh
 ./get_helm.sh 
ls -l /usr/local/bin/helm
 # kcli download helm
 # The correct image name is ghcr.io/helm/tiller, not gcr.io/kubernetes-helm/tiller.
 # helm install hub artifact-hub/artifact-hub
 #  helm install hub artifact-hub/artifact-hub |  kubeVersion: >= 1.19.0-0
 # list of repos : jFrog ChartCenter | Artifact Hub | Helm Hub | KubeApps Hub
 # https://artifacthub.io/packages/helm/artifact-hub/artifact-hub
sleep 10
 #helm init --stable-repo-url=https://charts.helm.sh/stable 
 # the helm init command has been removed without replacement: repo/dir setup is now automated (Tiler not needed)
/usr/local/bin/helm repo add stable https://charts.helm.sh/stable
/usr/local/bin/helm repo add bitnami https://charts.bitnami.com/bitnami
 
/usr/local/bin/helm search repo list
 # helm search repo bitnami | stable
 # helm repo update  # Make sure we get the latest list of charts
 # helm show all bitnami/mysql
 # helm show chart bitnami/mysql
 # $ helm install mysql-a bitnami/mysql --generate-nam
 #  helm list
 #--client-only
 # By using --client-only, you're setting up Helm to work in a client-only mode, where it won't try to connect 
 # to a Tiller server, which is required in Helm v2 but deprecated in Helm v3.
 
echo "******************************************************************************"
echo "Install k9s." `date`
echo "******************************************************************************"
 
wget -q https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_linux_amd64.rpm
yum localinstall -q -y k9s_linux_amd64.rpm
k9s version

echo "******************************************************************************"
echo "Install Aliasses." `date`
echo "******************************************************************************"

echo "Install the kubernetes Autocompletion "
 yum -q -y install bash-completion
# bash completion for K8
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
# add aliases and source bash completion
cat /vagrant/scripts/k8s/aliases.sh >> ~/.bashrc

echo "******************************************************************************"
echo "DevSecops." `date`
echo "******************************************************************************"
echo
NC='\033[0m'
echo "Kubescape"
curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash
echo -e "${NC}installation done"

# optional Glow for Readme.md rendering
#
# echo '[charm]
# name=Charm
# baseurl=https://repo.charm.sh/yum/
# enabled=1
# gpgcheck=1
# gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
# yum install glow
