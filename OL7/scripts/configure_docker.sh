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
# As part of the platform upgrade, the Docker was also upgraded to v24. 
# since then Docker dropped support for the overlay2.override_kernel_check storage
# 2024 remove the following line  "storage-opts": ["overlay2.override_kernel_check=true"]
# 2024 overlay2: docker is storing images on a file system that is not mounted with redirect_dir=off
# but by default OVERLAY_FS_REDIRECT_DIR kernel option is enabled
#
#
systemctl enable docker.service
echo "adapt the cgroup driver of Docker to systemd"
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl daemon-reload
systemctl start docker
#cat /etc/docker/daemon.json
systemctl status docker.service
docker info |grep 'Storage\|Filesystem'
lsmod |grep overlay
