simple nginx loadbalancer for development purposes running inside an lxc container

The loadbalancer container is limited to 8096mb of ram, you can change this in the start.sh script


replace the server list in loadbalancer.conf under upstream controllers with your IPs as well as the target port and listen port

### How to use
run: ./start.sh

reload any changes made to loadbalancer.conf: ./reload_config.sh
