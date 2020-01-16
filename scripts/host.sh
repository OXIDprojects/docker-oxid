#! /bin/bash
# GPL 3 or newer
# this is a polyfill for a docker host alias
# host.docker.internal on linux systems
if getent hosts host.docker.internal
then
   echo -e "\n host.docker.internal already exists"
else
   echo -e "`/sbin/ip route|awk '/default/ { print $3 }'`\thost.docker.internal" >> /etc/hosts
   echo "added host.docker.internal to hosts"
fi
