#!/bin/bash

export DEBIAN_FRONTEND='non-interactive'

echo -e "slapd slapd/root_password password admin" |debconf-set-selections
echo -e "slapd slapd/root_password_again password admin" |debconf-set-selections
echo -e "slapd slapd/internal/adminpw password admin" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password test" |debconf-set-selections
echo -e "slapd slapd/password2 password admin" |debconf-set-selections
echo -e "slapd slapd/password1 password admin" |debconf-set-selections

echo -e "slapd slapd/domain string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd shared/organization string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd slapd/backend string MDB" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
echo -e "slapd slapd/allow_ldap_v2 boolean false" |debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections

apt-get install -y slapd ldap-utils
sudo dpkg-reconfigure slapd

