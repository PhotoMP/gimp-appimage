#! /bin/bash

#---------------------------------------------------------------------------------

# Hotfix for building GTK 2 and 3 using GitHub CI

[ ! "${1}" = "--hook-to-build-both" ] && {
  export GTK_VERSION=2
  "${0}" --hook-to-build-both || exit 1
  export GTK_VERSION=3
  "${0}" --hook-to-build-both || exit 1
  exit
}

#---------------------------------------------------------------------------------

if [ x"${GTK_VERSION}" = "x" ]; then
	export GTK_VERSION=2
fi


if [ x"${GTK_VERSION}" = "x3" ]; then
  bash /sources/build-appimage-gtk3.sh || exit 1
else
  bash /sources/build-appimage.sh || exit 1
fi

export APPROOT=/work/appimage

# copy hook scripts
(mkdir -p "${APPROOT}/scripts" && \
cp -a /sources/scripts/gimp.sh "${APPROOT}/scripts" && \
cp -a /sources/appimage-helper-scripts/bundle-gtk2.sh "${APPROOT}/scripts" &&
cp -a /sources/appimage-helper-scripts/bundle-gobject-introspection.sh "${APPROOT}/scripts") || exit 1
if [ x"${GTK_VERSION}" = "x3" ]; then
  cp -a /sources/appimage-helper-scripts/bundle-python3.sh "${APPROOT}/scripts" || exit 1
else
  cp -a /sources/appimage-helper-scripts/bundle-python.sh "${APPROOT}/scripts" || exit 1
fi
bash /sources/package-appimage.sh || exit 1
exit 0

if [ x"${GTK_VERSION}" = "x4" ]; then
	# fill and package the AppImage bundle
	bash /sources/package-appimage.sh || exit 1
	exit 0
fi

(mkdir -p "${APPROOT}/scripts" && cp -a /sources/scripts/gmic.sh "${APPROOT}/scripts") || exit 1
bash /sources/build-appimage-plugins.sh || exit 1
bash /sources/package-appimage.sh "-withplugins" || exit 1
