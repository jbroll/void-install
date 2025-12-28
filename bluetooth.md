  386  sudo xbps-install -S bluez
  387  sudo xbps-install -S blueman
  388  sudo xbps-install -S bluez-utils
  389  sudo ln -s /etc/sv/bluetoothd /var/service/
  390  sudo sv start bluetoothd
  391  sudo sv status bluetoothd
