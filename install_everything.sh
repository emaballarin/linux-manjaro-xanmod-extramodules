#!/bin/zsh

#
# Linux kernel and extramodules support for AUR package 'linux-manjaro-xanmod'
# by Andrey Alekseev <andrey.android7890@gmail.com>
#
# Maintainer: Emanuele Ballarin <emanuele@ballarin.cc>
#
# Originally ported from the 'Clearer Manjaro' kernel stack
# (https://github.com/emaballarin/clearer-manjaro-kernel |
#  https://github.com/emaballarin/clearer-manjaro-kernel-nvidia |
#  https://github.com/emaballarin/clearer-manjaro-kernel-acpi-call)
#
# Builtin   extramodules: (a) wireguard, (b) Oracle VirtualBox Guest
# Supported extramodules: (1) nvidia,    (2) acpi_call.
#

# LINUX:
_LINUXVRS="58"
_LINUXVRS_DOT="5.8"
_LINUXPREFIX="MANJARO-Xanmod"

# NVIDIA VERSION:
_NVVER="450"
_NVSVER="66"

# ACPI_CALL VERSION:
_ACPICVER="1.1.0"


####################
## Set some flags ##
####################
unset CXXFLAGS
unset CFFLAGS
unset CFLAGS
unset FFLAGS
unset LDFLAGS
export CXXFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -fno-plt -march=native -fvisibility-inlines-hidden -Wl,--enable-new-dtags"
export CFFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -malign-data=abi -fno-semantic-interposition -ftree-vectorize -ftree-loop-vectorize -Wl,-sort-common -Wl,--enable-new-dtags -fno-plt -march=native"
export CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -fno-plt -march=native"
export FFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -malign-data=abi -fno-semantic-interposition -ftree-vectorize -ftree-loop-vectorize -Wl,--enable-new-dtags -march=native"
export LDFLAGS="-Wl,-O3,--sort-common,--as-needed,-z,relro,-z,now"

##################
## Get the code ##
##################

# Export variables
export MJXAN_TMPDIR="$(pwd)/TMPDIR"
export MJXAN_PKGS="$(pwd)/PKGS"

# Prepare build/install structure
mkdir -p "$MJXAN_TMPDIR"
mkdir -p "$MJXAN_PKGS"

# Clean-up (eventual) previous build
cd "$MJXAN_TMPDIR"
rm -R -f ./*

# Clone relevant git repositories
cd "$MJXAN_TMPDIR"

git clone --recursive https://aur.archlinux.org/linux-manjaro-xanmod.git
git clone --recursive https://gitlab.manjaro.org/packages/extra/linux${_LINUXVRS}-extramodules/nvidia-${_NVVER}xx.git
git clone --recursive https://gitlab.manjaro.org/packages/extra/linux${_LINUXVRS}-extramodules/acpi_call.git

bash -c "read -p '[[DIAG]] Was the whole build process successful? Press [ENTER] to deploy and install Manjaro clearer!'"

####################
## Patch the code ##
####################

# linux${_LINUXPREFIX}
cd "$MJXAN_TMPDIR/linux-manjaro-xanmod"
cp ../../emaballarin_reflopt.patch ./
git apply ./emaballarin_reflopt.patch

# nvidia-${_NVVER}xx
cd "$MJXAN_TMPDIR/nvidia-${_NVVER}xx"
cp ../../emaballarin_nvopt.patch ./
git apply ./emaballarin_nvopt.patch
cp -f ../../NVIDIA-Linux-x86_64-${_NVVER}.${_NVSVER}-no-compat32.run ./
cp ../../emaballarin_nvperformance.patch ./
sed -i "s/# patches here/patch -Np1 -i ..\/..\/emaballarin_nvperformance.patch/g" ./PKGBUILD
mv ./nvidia.install ./nvidia-${_LINUXPREFIX}.install
sed -i "s/_linuxprefix=.*/_linuxprefix=linux-manjaro-xanmod/g" ./PKGBUILD
sed -i "s/_extramodules=.*/_extramodules=extramodules-${_LINUXVRS_DOT}-${_LINUXPREFIX}/g" ./PKGBUILD
sed -i "s/install=\$_pkgname\.install.*/install=nvidia-${_LINUXPREFIX}\.install/g" ./PKGBUILD
sed -i "s/nvidia\.install/nvidia-${_LINUXPREFIX}\.install/g" ./PKGBUILD

# acpi_call
cd "$MJXAN_TMPDIR/acpi_call"
cp ../../emaballarin_acpiopt.patch ./
git apply ./emaballarin_acpiopt.patch
cp -f ../../v1.1.0.tar.gz ./
mv ./acpi_call.install ./acpi_call-${_LINUXPREFIX}.install
sed -i "s/_linuxprefix=.*/_linuxprefix=linux-manjaro-xanmod/g" ./PKGBUILD
sed -i "s/_extramodules=.*/_extramodules=extramodules-${_LINUXVRS_DOT}-${_LINUXPREFIX}/g" ./PKGBUILD
sed -i "s/install=\$_pkgname\.install.*/install=acpi_call-${_LINUXPREFIX}\.install/g" ./PKGBUILD
sed -i "s/acpi_call\.install/acpi_call-${_LINUXPREFIX}\.install/g" ./PKGBUILD

####################
## Build packages ##
####################

cd "$MJXAN_TMPDIR/linux-manjaro-xanmod"
makepkg -Csfi --noconfirm

cd "$MJXAN_TMPDIR/nvidia-${_NVVER}xx"
makepkg -Csf --noconfirm

cd "$MJXAN_TMPDIR/acpi_call"
makepkg -Csf --noconfirm

#####################
## Deploy packages ##
#####################

# Ask if deployment/install is really wanted
echo ' '
bash -c "read -p '[[DIAG]] Was the whole build process successful? Press [ENTER] to deploy and install Manjaro clearer!'"
echo ' '

# Remove (eventually) previously built packages
rm -R -f "$MJXAN_PKGS/*"

cd "$MJXAN_TMPDIR/clearer-manjaro-kernel"
cp ./*.pkg.tar.xz "$MJXAN_PKGS"

cd "$MJXAN_TMPDIR/clearer-manjaro-kernel-nvidia"
cp ./*.pkg.tar.xz "$MJXAN_PKGS"

cd "$MJXAN_TMPDIR/acpi_call"
cp ./*.pkg.tar.xz "$MJXAN_PKGS"

######################
## Install packages ##
######################
cd "$MJXAN_PKGS"
sudo pacman -U ./* --noconfirm
trizen -S wireguard-tools --noconfirm

# Ask for file cleanup
echo ' '
bash -c "read -p '[[DIAG]] If the installation was successful, press [ENTER] to perform a file cleanup. Hit [CTRL]+[C] to exit without cleanup.'"
echo ' '

rm -R -f "$MJXAN_TMPDIR"
rm -R -f "$MJXAN_PKGS"
