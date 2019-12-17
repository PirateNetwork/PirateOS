 #!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : openSUSE KIWI Image System
# COPYRIGHT     : (c) 2006,2007,2008,2017 SUSE Linux GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>, Stephan Kulow <coolo@suse.de>, Fabian Vogt <fvogt@suse.com>
#               :
# LICENSE       : BSD
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

set -euox pipefail

#--------------------------------------
# enable and disable services

for i in NetworkManager tlp tlp-sleep avahi-dnsconfd; do
	systemctl -f enable $i
done
for i in purge-kernels sshd wicked auditd apparmor; do
	systemctl -f disable $i
done

cd /

rm -rf /var/cache/zypp/raw/*

#======================================
# /etc/sudoers hack to fix #297695 
# (Installation Live CD: no need to ask for password of root)
#--------------------------------------
sed -i -e "s/ALL ALL=(ALL) ALL/ALL ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers 
chmod 0440 /etc/sudoers

/usr/sbin/useradd -m -u 999 linux -c "To Hodl or not to Hodl" -p "" 

# delete passwords
passwd -d linux
passwd -d root

# empty password is ok
pam-config -a --nullok

: > /var/log/zypper.log

chown -R linux:users /home/linux

chkstat --system --set

rm -rf /var/cache/zypp/packages

# bug 544314, we only want to disable the bit in common-auth-pc
sed -i -e 's,^\(.*pam_gnome_keyring.so.*\),#\1,'  /etc/pam.d/common-auth-pc

ln -s /usr/lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER_AUTOLOGIN linux
baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
baseUpdateSysConfig /etc/sysconfig/keyboard YAST_KEYBOARD "english-us,pc104"
baseUpdateSysConfig /etc/sysconfig/keyboard COMPOSETABLE "clear latin1.add"

baseUpdateSysConfig /etc/sysconfig/language RC_LANG "en_US.UTF-8"

baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT "eurlatgr.psfu"
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_SCREENMAP trivial
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_MAGIC "(K"
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_ENCODING "UTF-8"

baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER lightdm

###baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM gnome

#Disable journal write to disk in live mode, bug 950999
echo "Storage=volatile" >> /etc/systemd/journald.conf

#======================================
# GeckoLinux
#--------------------------------------
rm -R /etc/skel/bin
rm /usr/share/fonts/truetype/Ubuntu-M.ttf
rm /usr/share/fonts/truetype/Ubuntu-MI.ttf



## Fix gvfs-trash functionality for live session user
mkdir /.Trash-999
chown 999:users /.Trash-999
chmod 700 /.Trash-999

# Specific to XFCE
#--------------------------------------
rm /usr/share/wallpapers/xfce/default.wallpaper
ln -s /usr/share/wallpapers/Zwopper-Green-Dew-CC-BY-SA-30-2560x1600.png /usr/share/wallpapers/xfce/default.wallpaper
