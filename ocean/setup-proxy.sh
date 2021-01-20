#!/bin/bash
DOMAIN="www.gamyam.net"
JENKINS_IPV4=
JENKINS_HTTP_PORT=8080
JENKINS_IPV6=
JENKINS_HTTPS_PORT=8081

NGINX_IPV4=
NGINX_HTTP_PORT=80
NGINX_IPV6=
NGINX_HTTPS_PORT=443

CUR_USER=`whoami`
if [ "$CUR_USER" != "root" ]; then
  echo "Not root yet"
  exit 1
fi

if [ "" == "$1" ]; then
  echo "Please provide domain name:"
  echo "  setup-proxy.sh full.domain.name Private.IP.Address"
  exit 1
fi
DOMAIN=$1

if [ "" == "$2" ]; then
  echo "Please provide Private IP address to Jenkins master"
  echo "  setup-proxy.sh full.domain.name Private.IP.Address"
  exit 1
fi
IPADDR=$2

cd /etc/nginx/sites-available
if [ -f webproxy.conf ]; then
  rm webproxy.conf
fi
wget https://raw.githubusercontent.com/svangeepuram/jenkins-bootcamp-course/master/aws/lightsail/scale/webproxy.conf
sed -i "s/DOMAIN_NAME/$DOMAIN/g" webproxy.conf

sed -i "s/NGINX_IPV4/$NGINX_IPV4/g" webproxy.conf
sed -i "s/NGINX_HTTP_PORT/$NGINX_HTTP_PORT/g" webproxy.conf
sed -i "s/NGINX_IPV6/$NGINX_IPV6/g" webproxy.conf
sed -i "s/NGINX_HTTPS_PORT/$NGINX_HTTPS_PORT/g" webproxy.conf

sed -i "s/JENKINS_IPV4/$JENKINS_IPV4/g" webproxy.conf
sed -i "s/JENKINS_HTTP_PORT/$JENKINS_HTTP_PORT/g" webproxy.conf
sed -i "s/JENKINS_IPV6/$JENKINS_IPV6/g" webproxy.conf
sed -i "s/JENKINS_HTTPS_PORT/$JENKINS_HTTPS_PORT/g" webproxy.conf

#sed -i "s//$/g" webproxy.conf

cd ../sites-enabled
if [ -e default ]; then
  rm default
fi
if [ -e web.conf ]; then
  rm web.conf
fi
if [ -e web-secured.conf ]; then
  rm web-secured.conf
fi
if [ -e webproxy.conf ]; then
  rm webproxy.conf
fi
ln -s ../sites-available/webproxy.conf webproxy.conf

nginx -t

systemctl restart nginx
