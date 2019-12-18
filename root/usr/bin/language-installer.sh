#!/bin/bash

echo "Installing basic language packs. This might take a while..."
zypper --gpg-auto-import-keys --no-gpg-checks --non-interactive refresh
zypper --non-interactive in desktop-translations
zypper --non-interactive in MozillaFirefox-translations-common
zypper --non-interactive in MozillaThunderbird-translations-common

echo "Locating and installing other language packs. This might take a while..."
zypper search -t package "*-lang" | awk '{print $2}' > /tmp/lang-packages
sed -i '/gstreamer/d' /tmp/lang-packages
rpm -qa --queryformat "%{NAME}\n" > /tmp/installed-packages
to_install=""
while read p; do
    if grep -qw "^${p}-lang$" /tmp/lang-packages; then
        to_install="$to_install ${p}-lang"
    fi
done </tmp/installed-packages
if [ -n "$to_install" ]; then
    zypper -n in $to_install
fi

echo "Done! Now you can manually install other language packs under the LANGUAGE tab in YaST Software."
/usr/sbin/yast2 sw_single --qt
