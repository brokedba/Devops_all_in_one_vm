echo "******************************************************************************"
echo "Prepare the drive for the docker images." `date`
echo "******************************************************************************"
ls /dev/sd*
echo -e "n\np\n\n\n\nw" | fdisk /dev/sdc
ls /dev/sdc*
echo "options overlay metacopy=off redirect_dir=off"> /etc/modules-load.d/overlay_native_mode.conf
modprobe -r overlay
modprobe overlay
docker-storage-config -s overlay2 -d /dev/sdc1
echo "******************************************************************************"
echo "Enable Docker." `date`
echo "******************************************************************************"
#cat > /etc/sysconfig/docker-storage-setup <<EOF
#STORAGE_DRIVER=overlay2
#DEVS=/dev/sdc1
#EOF 
systemctl enable docker.service
echo "adapt the cgroup driver of Docker to systemd"
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": ["overlay2.override_kernel_check=true"]
}
EOF
systemctl daemon-reload
systemctl start docker
#cat /etc/docker/daemon.json
systemctl status docker.service
docker info |grep 'Storage\|Filesystem'
lsmod |grep overlay
