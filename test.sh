sudo chmod 777 /etc/nsswitch.conf
cat<<EOF >/etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.

# `info libc "Name Service Switch"` for information about this file.
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
