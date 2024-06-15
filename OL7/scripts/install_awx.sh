echo "******************************************************************************"
echo "Install Ansible" `date`
echo "******************************************************************************"
#python3 -m pip install --user ansible
. ~/.bashrc
echo "python3 path"
which python3
echo " ...hardcode the path"
alias python3='/usr/local/bin/python3.11'
alias pip3='/usr/local/bin/pip3.11'
which python3
which pip3
sleep 10
pip3 install pyyaml==5.3.1
pip3 install ansible
#python3.11 -m pip install -q ansible
echo "check version"
which ansible
/usr/local/bin/ansible --version
echo "******************************************************************************"
echo "Install AWX" `date`
echo "******************************************************************************"
# pip3 install --upgrade pip
pip3 install --upgrade setuptools 
# pip3 install pyyaml==5.3.1
#pip3 install docker-py
pip3 uninstall docker-py docker
echo "============ AWX DOCKER COMPOSE"
# git clone -b 17.0.1 https://github.com/ansible/awx.git
# pip3 install docker-compose --- version too old
# Download the file silently
wget -q -O docker-compose https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 
# Apply execute permissions
chmod o+x docker-compose
# Move the file to the desired location
mv -f docker-compose  /usr/local/bin

# change dir to awx istall directory
 
 cd /vagrant/scripts/awx/installer
# ( if you skip this step AWX will never see this directory as local source of playbook files!! )
mkdir -p ${PROJECT_DATA_DIR}/test
/bin/cp -f ./inventory.template ./inventory
# For a real installation, you will probably need to change many of these.
sed -i -e "s|awx_task_hostname=awx|awx_task_hostname=${AWX_TASK_HOSTNAME}|g" ./inventory
sed -i -e "s|awx_web_hostname=awxweb|awx_web_hostname=${AWX_WEB_HOSTNAME}|g" ./inventory
sed -i -e "s|^# awx_official=false|awx_official=true|g" ./inventory
sed -i -e "s|postgres_data_dir=\"~/.awx/pgdocker\"|postgres_data_dir=${POSTGRES_DATA_DIR}|g" ./inventory

# Don't change, unless you are changing the Vagrant port forwarding.
sed -i -e "s|host_port=80|host_port=${HOST_PORT}|g" ./inventory
sed -i -e "s|host_port_ssl=443|host_port_ssl=${HOST_PORT_SSL}|g" ./inventory

sed -i -e "s|docker_compose_dir=\"~/.awx/awxcompose\"|docker_compose_dir=${DOCKER_COMPOSE_DIR}|g" ./inventory
# rabbitmq is replaced by reis in 17.0.1
sed -i -e "s|pg_username=awx|pg_username=${PG_USERNAME}|g" ./inventory
sed -i -e "s|pg_password=awxpass|pg_password=${PG_PASSWORD}|g" ./inventory
sed -i -e "s|pg_database=awx|pg_database=${PG_DATABASE}|g" ./inventory
sed -i -e "s|pg_port=5432|pg_port=${PG_PORT}|g" ./inventory
sed -i -e "s|admin_user=admin|admin_user=${ADMIN_USER}|g" ./inventory
sed -i -e "s|admin_password=password|admin_password=${ADMIN_PASSWORD}|g" ./inventory

sed -i -e "s|secret_key=awxsecret|secret_key=${SECRET_KEY}|g" ./inventory

sed -i -e "s|#project_data_dir=/var/lib/awx/projects|project_data_dir=${PROJECT_DATA_DIR}|g" ./inventory

############################################
echo "===== AWX installation is starting up"
############################################
### NOTE : the playbook tasks have been changed to use bultin docker-compose instead of ansible docker compose
### steps start and stop containers
# check path
sleep 10
echo "check path"
which ansible-playbook
/usr/local/bin/ansible-playbook -i inventory install.yml -v
# run twice because "Create Preload data" usually fails the first time  https://github.com/ansible/awx/issues/8863
/usr/local/bin/ansible-playbook -i inventory install.yml  --start-at-task 'Create Preload data' -v

############################################
echo "============ AWX CLI "
############################################
cd /u01/
# install the AWX CLI 
pip3 install awxkit
awx --help
# build CLI documentation
pip3 install -q sphinx sphinxcontrib-autoprogram
cd awxkit/awxkit/cli/docs
TOWER_HOST=https:127.0.0.1 TOWER_USERNAME=admin TOWER_PASSWORD=password make clean html
cd build/html/ && python3 -m http.server
