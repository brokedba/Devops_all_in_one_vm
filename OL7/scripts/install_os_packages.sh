echo "******************************************************************************"
echo "Prepare yum with the latest repos." `date`
echo "******************************************************************************"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

cd /etc/yum.repos.d
rm -f public-yum-ol7.repo
rm -f uek-ol7.repo
rm -f oracle-linux-ol7.repo
wget http://yum.oracle.com/public-yum-ol7.repo
yum install -y yum-utils zip unzip
yum-config-manager --enable ol7_optional_latest
yum-config-manager --enable ol7_addons
yum-config-manager --enable ol7_preview
yum-config-manager --enable ol7_developer
yum-config-manager --enable ol7_developer_EPEL

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
EOF

yum repolist
echo "******************************************************************************"
echo "Install Docker and Ansible." `date`
echo "******************************************************************************"
yum install -y docker-engine yum-plugin-ovl   # btrfs-progs btrfs-progs-devel
yum install -y ansible python-3 python3-pip  python3-devel
yum install -y bind-utils xterm tcpdump
# AWX requirement.
yum install -y git gcc

#yum update -y
