export AWX_TASK_HOSTNAME=awx
export AWX_WEB_HOSTNAME=awxweb

export POSTGRES_DATA_DIR=/u01/pgdocker

# Don't change, unless you are changing the Vagrant port forwarding.
export HOST_PORT=8090
export HOST_PORT_SSL=4443

export DOCKER_COMPOSE_DIR=/u01/awxcompose

export PG_USERNAME=awx
export PG_PASSWORD=awxpass
export PG_DATABASE=awx
export PG_PORT=5432

export RABBITMQ_PASSWORD=awxpass

export ADMIN_USER=admin
export ADMIN_PASSWORD=password

export SECRET_KEY=awxsecret

export PROJECT_DATA_DIR=/u01/projects