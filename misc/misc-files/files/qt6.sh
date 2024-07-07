# Begin /etc/profile.d/qt6.sh

QT6DIR=/usr

export PATH=$PATH:$QT6DIR/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$QT6DIR/lib/pkgconfig

export QT_PLUGIN_PATH=$QT_PLUGIN_PATH:/usr/lib/plugins:$QT6DIR/lib/plugins
export QML2_IMPORT_PATH=$QML2_IMPORT_PATH:/usr/lib/qt6/qml:$QT6DIR/lib/qml

export QT6DIR

# End /etc/profile.d/qt6.sh
