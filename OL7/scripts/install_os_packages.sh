echo "******************************************************************************"
echo "Prepare yum with the latest repos." `date`
echo "******************************************************************************"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

cd /etc/yum.repos.d
rm -f public-yum-ol7.repo
rm -f uek-ol7.repo
rm -f oracle-linux-ol7.repo
#wget http://yum.oracle.com/public-yum-ol7.repo
yum-config-manager --enable ol7_optional_latest
yum-config-manager --enable ol7_addons
yum-config-manager --enable ol7_preview
yum-config-manager --enable ol7_developer
yum-config-manager --enable ol7_developer_EPEL
yum-config-manager --add-repo http://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64

cat <<EOF >> /etc/yum.repos.d/public-yum-ol7.repo
[ol7_UEKR6]
name=Latest Unbreakable Enterprise Kernel Release 6 for Oracle Linux $releasever (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/UEKR6/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ovirt43]
name=Oracle Linux $releasever Ovirt 4.3 (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/ovirt43/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ovirt43_extras]
name=Oracle Linux $releasever Ovirt 4.3 extras (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/ovirt43/extras/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[gluster6]
name=Oracle Linux $releasever gluster 6 (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/gluster6/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[centos-extras]
name=Centos extras - $basearch
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=1
gpgkey=http://centos.org/keys/RPM-GPG-KEY-CentOS-7
EOF

yum repolist

echo "******************************************************************************"
echo "Install Docker" `date`
echo "******************************************************************************"
yum install -y yum-utils zip unzip redhat-lsb-core screen
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum install -q -y docker-engine 
yum install -q -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin # docker-cli
yum install -q -y yum-plugin-ovl   # btrfs-progs btrfs-progs-devel 
# yum install -q -y python-3 python3-pip  python3-devel ansible 
yum install -q -y bind-utils xterm tcpdump java-11-openjdk-devel
# AWX requirement.
yum install -y git gcc
# K8 CRI
systemctl enable containerd
systemctl start containerd

echo "******************************************************************************"
echo "Install OpenSSL & Python 3.11" `date`
echo "******************************************************************************"
# install the AWX CLI 
echo "======> install Openssl 1.1.1"
sudo yum -y install epel-release 
sudo yum -y install wget make cmake gcc bzip2-devel libffi-devel zlib-devel
sudo yum -y groupinstall "Development Tools"
gcc --version
# After installing OpenSSL 1.1.1, verify by checking the version:
openssl version
echo "remove old version"
yum -y remove openssl openssl-devel
wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar xf openssl-1.1.1w.tar.gz
cd openssl-1.1*/
# Configure OpenSSL. You can specify
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
# Build OpenSSL 1.1.x using make command. in parallel
make -s -j $(nproc)
# Install OpenSSL 1.1.1 on CentOS 7 / RHEL 7
sudo make install -s -j $(nproc)
# Update the shared libraries cache.
sudo ldconfig
# Update your system-wide OpenSSL configuration:
sudo tee /etc/profile.d/openssl.sh<<EOF
export PATH=/usr/local/openssl/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/openssl/lib:\$LD_LIBRARY_PATH
EOF
# - Reload shell environment:
source /etc/profile.d/openssl.sh
echo "Confirm new version"
openssl version
echo "==========="
echo "Python 3.11"
echo "==========="
wget -q https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz
tar xf Python-3.11.6.tgz
cd Python-3.11*/
LDFLAGS="${LDFLAGS} -Wl,-rpath=/usr/local/openssl/lib" ./configure --with-openssl=/usr/local/openssl 
echo "..Build Python 3.11 using make command. in parallel"
make -s -j $(nproc)
echo "..Install Python 3.11 on CentOS 7 / RHEL 7 altinstall avoid conflicts with existing binaries"
sudo make altinstall -s -j $(nproc)
echo
echo "===== Confirm new version:"
python3.11 --version
sudo echo -en "alias python3='/usr/local/bin/python3.11';alias pip3='/usr/local/bin/pip3.11'" >> ~/.bashrc
. ~/.bashrc
ls -lrth /bin/python*
unlink /bin/python3
ln -s /usr/local/bin/python3.11 /bin/python3
python3 --version 

# yum repo-pkgs docker-ce-stable list 