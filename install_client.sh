#!/bin/bash

sudo apt update
export DEBIAN_FRONTEND=noninteractive

echo -e "ldap-auth-config ldap-auth-config/bindpw password admin" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/rootbindpw password admin" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/move-to-debconf boolean true" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/override boolean true" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/dblogin boolean false" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/pam_password select md5" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/rootbinddn string cn=admin,dc=clemson,dc=cloudlab,dc=us" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=clemson,dc=cloudlab,dc=us" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://192.168.1.1" | sudo debconf-set-selections
#echo -e "ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net" | sudo debconf-set-selections
echo -e "ldap-auth-config ldap-auth-config/dbrootlogin boolean true" | sudo debconf-set-selections

sudo apt install -y libnss-ldap libpam-ldap ldap-utils

sudo chmod 777 /etc/nsswitch.conf
cat<<EOF >/etc/nsswitch.conf

passwd: compat systemd ldap
group:  compat systemd ldap
shadow: compat
gshadow: files
hosts: files dns
networks: files
protocols: db files
services: db files
ethers: db files
rpc: db files
netgroup: nis
EOF

sudo chmod 777 /etc/pam.d/common-password
cat<<EOF >/etc/pam.d/common-password
password [success=2 default=ignore] pam_unix.so obscure sha512
password [success=1 user_unknown=ignore default=die] pam_ldap.so try_first_pass
password requisite pam_deny.so
password required pam_permit.so
EOF

sudo chmod 777 /etc/pam.d/common-session
cat<<EOF >/etc/pam.d/common-session
session [default=1] pam_permit.so
session requisite pam_deny.so
session required pam_permit.so
session optional pam_umask.so
session required pam_unix.so
session optional              pam_ldap.so
session optional pam_systemd.so
session optional pam_mkhomedir.so skel=/etc/skel umask=077
EOF

getent passwd student

sudo su - student
