#!/bin/sh

cat <<EOT > /etc/default/dropbear
NO_START=0
DROPBEAR_PORT=2222
EOT

cat <<EOT > /config/dropbear
NO_START=0
DROPBEAR_PORT=2222
EOT

/etc/init.d/dropbear start

echo -e "toor\ntoor" | passwd root