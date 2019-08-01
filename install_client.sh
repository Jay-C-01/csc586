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
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.
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
#
# /etc/pam.d/common-password - password-related modules common to all services
#
# This files is included from other service-specific PAM config files,
# and should contain a list of modules that define the services to be
# used to change user passwords. The default is pam_unix.
# Explanation of pam_unix options:
#
# The "sha512" option enables salted SHA512 passwords. Without this option,
# the default is Unix crypt. Prior releases used the option "md5".
#
# The "obscure" option replaces the old `OBSCURE_CHECKS_ENAB' option in
# login.defs.
#
# See the pam_unix manpage for other options.
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# TO take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules. See
# pam-auth-update(8) for details.
# here are the per-package modules (the "Primary" block)
password [success=2 default=ignore] pam_unix.so obscure sha512
password [success=1 user_unknown=ignore default=die] pam_ldap.so try_first_pass
# here's the fallback if no module succeeds
password requisite pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump aroun
password required pam_permit.so
# and here are more per-package modules (the "Additional" block)
# end of pam-auth-update config
EOF

sudo chmod 777 /etc/pam.d/common-session
cat<<EOF >/etc/pam.d/common-session
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of sesssions of *any* kind (both interactive and
# non-interactive).
#
# As of pam 1.0.1-6, this file us managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, abd use
# pam-auth-update to manage selection of other modules. See
# pam-auth-update (8) for details.
# here are the per-package modules (the "Primary" block)
session [default=1] pam_permit.so
# here's the fallback if no module succeeds
session requisite pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session required pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional pam_umask.so
# and here are more per-package modules (the "Additional" block)
session required pam_unix.so
session optional              pam_ldap.so
session optional pam_systemd.so
session optional pam_mkhomedir.so skel=/etc/skel umask=077
# end of pam-auth-update config
EOF

getent passwd student

sudo su - student
