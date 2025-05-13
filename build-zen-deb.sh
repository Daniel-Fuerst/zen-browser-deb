#!/bin/bash

cd /tmp
wget https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz
tar -xvf zen.linux-x86_64.tar.xz
cd zen

INFO_APP_INI="application.ini"

get_Version() {
    local section="App"
    local key="Version"
    local value=$(awk -F '=' "/^\[$section\]/{a=1}a==1&&\$1~/$key/{print \$2;exit}" "$INFO_APP_INI")
    echo "$value"
}

# Define package name and version
PACKAGE_NAME="zen-browser-deb"
VERSION=$(get_Version)
MAINTAINER="Your Self <yourself@example.com>"
DESCRIPTION=".deb wrapper for the Zen Browser tarball"

# Create the package directory structure
mkdir -p ${PACKAGE_NAME}/DEBIAN
mkdir -p ${PACKAGE_NAME}/usr/lib/zen
mkdir -p ${PACKAGE_NAME}/usr/share/applications

# Copy files into the package structure
cp -r * ${PACKAGE_NAME}/usr/lib/zen/
# Create the .desktop file
cat > ${PACKAGE_NAME}/usr/share/applications/zen.desktop <<EOF
[Desktop Entry]
Name=Zen
Comment=A short description of your application
Exec=/usr/lib/zen/zen
Icon=/usr/lib/zen/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Utility;
EOF

# Create the control file
cat > ${PACKAGE_NAME}/DEBIAN/control <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: base
Priority: optional
Architecture: all
Essential: no
Installed-Size: 1024
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
EOF

# Create postrm file
cat > ${PACKAGE_NAME}/DEBIAN/postrm <<'EOF'
#!/bin/sh

case "$1" in
    remove|purge|upgrade|failed-upgrade|abort-install|abort-upgrade|disappear)
        echo "Running post-removal script..."
        rm -rf /usr/lib/zen
        ;;
    *)
        echo "postrm called with unknown argument \`$1'" >&2
        exit 1
        ;;
esac

exit 0
EOF

chmod +x ${PACKAGE_NAME}/DEBIAN/postrm

# Build the package
dpkg -b ${PACKAGE_NAME} ${PACKAGE_NAME}-${VERSION}.deb

# Cleanup
mv ${PACKAGE_NAME}-${VERSION}.deb ~/Documents
cd /tmp
rm -rf zen*

echo "Package ${PACKAGE_NAME}-${VERSION}.deb created successfully."

