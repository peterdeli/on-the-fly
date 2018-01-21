#!/usr/bin/bash
#keep

prod_jump=httpd@ec2-34-207-153-170.compute-1.amazonaws.com
dev_jump=httpd@jump.east1.gcsdev.com

prod_dash=centos@10.0.4.164
dev_dash=centos@ip-10-0-3-74.ec2.internal

prod_jump_key=~/.ssh_aws/id_rsa
dev_jump_key=~/.ssh_aws/id_rsa

prod_dash_key=~/.ssh_aws/id_rsa
dev_dash_key=~/.ssh_aws/httpd_ec2

dev_dash_user=centos
dev_jump_user=httpd
prod_dash_user=centos
prod_jump_user=httpd

if [ "XX${INTERACTIVE:+1}" = "XX" ]; then
        # not set
        export INTERACTIVE=true
fi

if [ $INTERACTIVE = 'true' ]; then
	echo "interactive"
	read this
fi

env=$1
remote_file=$2
remote_type=$3
local_path=$4

if [ $# -ne 4 ]; then
	echo "env, remote file, remote type ( f,d ), local_path"
	echo -n "env: "; read env
	echo -n "remote_file: "; read remote_file
	echo -n "remote_type: "; read remote_type
	echo -n "local_path: "; read local_path
fi


if [[ $env = "prod" ]]; then
	jumphost=$prod_jump
	jump_key=$prod_jump_key
	dash=$prod_dash
	dash_key=$prod_dash_key
	dash_user=$prod_dash_user
	jump_user=$prod_jump_user
elif [[ $env = "dev" ]]; then
	jumphost=$dev_jump
	jump_key=$dev_jump_key
	dash=$dev_dash
	dash_key=$dev_dash_key
	dash_user=$dev_dash_user
	jump_user=$dev_jump_user
fi

if [ $remote_type = "d" ]; then
	SCP_CMD="scp -v -r "
else
	SCP_CMD="scp -v "
fi

cat <<EOF
$SCP_CMD -i $dash_key -o ProxyCommand="ssh -i ~/.ssh_aws/id_rsa -W %h:%p $jumphost" ${dash}:${remote_file} $local_path | tee /tmp/xfer.out.$$ 2>&1 &
EOF
read this

$SCP_CMD -i $dash_key -o ProxyCommand="ssh -i ~/.ssh_aws/id_rsa -W %h:%p $jumphost" ${dash}:${remote_file} $local_path | tee /tmp/xfer.out.$$ 2>&1 &
	
#nohup scp -r -i httpd_ec2 -o ProxyCommand="ssh -i id_rsa -W %h:%p httpd@jump.east1.gcsdev.com" centos@ip-10-0-3-74.ec2.internal:/home/centos ~/aws/ip-10-0-3-74_dashboard_server/. > /tmp/xfer.out 2>&1 &
