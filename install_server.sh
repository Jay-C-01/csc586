#!/bin/bash

sudo apt update

export DEBIAN_FRONTEND=noninteractive

echo -e "slapd slapd/root_password password admin" |sudo debconf-set-selections
echo -e "slapd slapd/root_password_again password admin" |sudo debconf-set-selections
echo -e "slapd slapd/internal/adminpw password admin" |sudo debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password test" |sudo debconf-set-selections
echo -e "slapd slapd/password2 password admin" |sudo debconf-set-selections
echo -e "slapd slapd/password1 password admin" |sudo debconf-set-selections

echo -e "slapd slapd/domain string clemson.cloudlab.us" |sudo debconf-set-selections
echo -e "slapd shared/organization string clemson.cloudlab.us" |sudo debconf-set-selections
echo -e "slapd slapd/backend string MDB" |sudo debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |sudo debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |sudo debconf-set-selections
echo -e "slapd slapd/allow_ldap_v2 boolean false" |sudo debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |sudo debconf-set-selections

sudo apt-get install -y slapd ldap-utils

sudo ufw allow ldap

PASS=$(slappasswd -s rammy)
cat<<EOF >/local/repository/users.ldif
dn: uid=student,ou=People,dc=clemson,dc=cloudlab,dc=us
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: student
sn: Ram
givenName: Golden
cn: student
displayName: student
uidNumber: 10000
gidNumber: 5000
userPassword: "$PASS"
gecos: Golden Ram
loginShell: /bin/dash
homeDirectory: /home/student
EOF

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w admin -f /local/repository/basedn.ldif

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -w admin -f /local/repository/users.ldif


