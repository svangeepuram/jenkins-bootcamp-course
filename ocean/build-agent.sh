add slave:

From root:
adduser --quiet --disabled-password --shell /bin/bash --gecos "ubuntu" ubuntu
passwd ubuntu

usermod -aG sudo ubuntu
rsync --archive --chown=ubuntu:ubuntu ~/.ssh /home/ubuntu

chmod 640 /etc/sudoers
cat <<EOF | tee -a /etc/sudoers
ubuntu ALL=(ALL) NOPASSWD: ALL
EOF
visudo -c
chmod 440 /etc/sudoers

from ubuntu :
sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu

sudo docker --version

sudo docker run -d --rm --name=agent2 -p 2222:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4Cb/0PCQc+zqec2BDkjNcVZ5vW7q9PhDNIL+MIX/oLNpqM+bNQwvp8ig6Y5lhrotHdIfL+SFRLsPQpoT1hNVMmLskEA6UVCMSZW2aI9lXvIh2y/EvFlM/FK3Sw1x8CwV5F8scRqtrb3vVnrdwDEmBO3TyE31WGfXtMNa36cBDyyYjAnwa8KSat4r3cmLdQUAoSbKgwH0l41JTwXNL8hDNKETb1NBOuwuiir+IN4unAl6xIVcSYi7xCHq8KZuL0/bUmbWQljIkPnYDLSWDyyveZ8DmNSzzvtYTl6kwoDe63rozsSnaP/XPW5/WALq0OB4puXWDiqq2uAgyosxhP6Dp malathi@slave1" \
jenkins/ssh-agent:alpine

sudo docker exec -it agent2 /bin/sh

env | egrep -v "^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)" >> /etc/environment

control p q

note down agent public ip, make sure port 2222 is open

eg: slave2:
142.93.85.219

in the ssh plugin conf, specify port and javapath
javapath:
/opt/java/openjdk/bin/java

port: 2222
==
