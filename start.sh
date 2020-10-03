#!/bin/bash
set -ex

sudo apt install conntrack
sudo modprobe br_netfilter

function create_lxc_node {

	local node_name=$1

	read -r -d '' raw_lxc <<RAW_LXC || true
lxc.apparmor.profile=unconfined
lxc.mount.auto=proc:rw sys:rw cgroup:rw
lxc.cgroup.devices.allow=a
lxc.cgroup.memory.limit_in_bytes=$2
lxc.cap.drop=
lxc.apparmor.allow_incomplete=1
RAW_LXC

	lxc launch  \
	--config security.privileged=true \
	--config security.nesting=true \
	--config linux.kernel_modules=ip_tables,ip6_tables,netlink_diag,nf_nat,overlay \
	--config raw.lxc="${raw_lxc}" \
	ubuntu:20.04 ${node_name}

	lxc config device add ${node_name} kmsg unix-char source=/dev/kmsg path=/dev/kmsg

	set +ex
	while :
	do
		lxc exec ${node_name} -- /bin/bash -c 'curl -s google.com' &> /dev/null
		retVal=$?
		if [ $retVal -eq 0 ]
		then
			break
		fi
		sleep 1
	done
	set -ex
}

function setup_lb {
	create_lxc_node $1 8096M

	lxc exec $1 -- /bin/bash -c "apt update && apt install -y nginx"
	lxc exec $1 -- /bin/bash -c "echo 'include /etc/nginx/loadbalancer.conf;' >> /etc/nginx/nginx.conf"
	
	./reload_config.sh
}
setup_lb load-balancer
