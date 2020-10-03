#!/bin/bash
set -ex

sudo lxc file push loadbalancer.conf load-balancer/etc/nginx/loadbalancer.conf
lxc exec load-balancer -- /bin/bash -c "sudo systemctl restart nginx && sudo systemctl enable nginx"
