#!/bin/bash

is_debian_based() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
      return 0  
    fi
  fi
  return 1  
}

is_arch_based() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
      return 0
    fi
  fi
  return 1
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

if [ ! -d "tung" ]; then
  echo "Missing the theme directory: tung"
  exit 1
fi

if [ ! -d "/usr/share/plymouth" ]; then
  printf "Plymouth needs to be installed, should it be installed? (Y/n) "
  read PLYMOUTH_INSTALL_ANSWER
  
  if [[ $PLYMOUTH_INSTALL_ANSWER == *Y* || $PLYMOUTH_INSTALL_ANSWER == *y* ]]; then
    echo "Installing plymouth"
  else
    echo "Not installing plymouth. Aborting."
    exit 1
  fi

  if is_debian_based; then
    echo "Debian detected, using apt"
    apt install plymouth -y
  elif is_arch_based; then
    echo "Arch detected, using pacman"
    yes | pacman -S plymouth
  else
    echo "Unkown distro, install plymouth yourself"
    exit 1
  fi
fi

echo "Installing"

cp -rv ./tung /usr/share/plymouth/themes/

printf "Installed. Do you want to set it as the current theme? (Y/n) "
read SELECT_THEME

if [[ $SELECT_THEME == *Y* || $SELECT_THEME == *y* ]]; then
  echo "Setting the theme"
  plymouth-set-default-theme tung
  echo "Regenerating initramfs"
  if is_debian_based; then
    echo "Debian based detected."
    update-initramfs -u
  elif is_arch_based; then
    echo "Arch based detected."
    mkinitcpio -P
  else
    echo "Distro undetected. You will have to regenerate initramfs yourself"
  fi
fi

echo "Finished. Enjoy :)"
