#!/usr/bin/bash
#keep

prod_jump=pu00gcsing006

prod_dash=pu0gcsdbs005

prod_jump_key=~/.ssh/id_rsa_1

prod_dash_key=~/.ssh_aws/id_rsa

dev_jump_user=httpd
prod_jump_user=pdelevor

if [[ $1 = "-help" ]]; then
	echo "env, remote file, remote type ( f,d ), local_path, scp type ( get/put )"
	exit
fi

if [ "XX${INTERACTIVE:+1}" = "XX" ]; then
        # not set
        export INTERACTIVE=true
fi

if [ $INTERACTIVE = 'true' ]; then
	echo "interactive"
	read this
fi

env=$1
remote_path=$2
xfer_type=$3
local_path=$4
scp_type=$5

if [ $# -ne 5 ]; then
	echo "env, remote file, remote type ( f,d ), local_path, scp type ( get/put )"
	echo -n "env: "; read env
	echo -n "remote_path: "; read remote_path
	echo -n "xfer_type: "; read xfer_type
	echo -n "local_path: "; read local_path
	echo -n "scp type ( get, put ): " ; read scp_type 
fi

jumphost=""
jump_key=""
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

if [ $xfer_type = "d" ]; then
	SCP_CMD="scp -v -r "
else
	SCP_CMD="scp -v "
fi

REMOTE=${dash}:${remote_path}
LOCAL=$local_path

if [ $scp_type = "get" ]; then

cat <<EOF
$SCP_CMD -o ProxyCommand="ssh -i $jump_key -W %h:%p $jumphost" $REMOTE $LOCAL  | tee /tmp/xfer.out.$$ 2>&1 &
EOF
    read this

    $SCP_CMD -o ProxyCommand="ssh -i $jump_key -W %h:%p $jumphost" $REMOTE $LOCAL | tee /tmp/xfer.out.$$ 2>&1 &
	
else

cat <<EOF
$SCP_CMD -o ProxyCommand="ssh -i $jump_key -W %h:%p $jumphost" $LOCAL $REMOTE | tee /tmp/xfer.out.$$ 2>&1 &
EOF
    read this

    $SCP_CMD -o ProxyCommand="ssh -i $jump_key -W %h:%p $jumphost" $LOCAL $REMOTE | tee /tmp/xfer.out.$$ 2>&1 &

fi

