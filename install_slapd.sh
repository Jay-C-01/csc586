#!/bin/bash

export DEBIAN_FRONTEND='non-interactive'

echo -e "slapd slapd/root_password password admin" |debconf-set-selections
echo -e "slapd slapd/root_password_again password admin" |debconf-set-selections
echo -e "slapd slapd/internal/adminpw password admin" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password test" |debconf-set-selections
echo -e "slapd slapd/password2 password admin" |debconf-set-selections
echo -e "slapd slapd/password1 password admin" |debconf-set-selections

dpkg-reconfigure slapd

