import QtQuick
import QtQuick.Controls


Item {
    property alias fontSize: m_menuExtraButtons.font.pointSize
    property alias menu: m_menuExtraButtons

    signal itemSaveTriggered()
    signal itemSaveAsTriggered()
    signal itemCloseTriggered()
    signal itemSettingsTriggered()

    Menu {
        id: m_menuExtraButtons

        MenuItem {
            text: qsTr("Save")

            onTriggered: {
                itemSaveTriggered()
            }
        }

        MenuItem {
            text: qsTr("Save as")

            onTriggered: {
                itemSaveAsTriggered()
            }
        }

        MenuItem {
            text: qsTr("Close")

            onTriggered: {
                itemCloseTriggered()
            }
        }

        MenuItem {
            text: qsTr("Settings")

            onTriggered: {
                itemSettingsTriggered()
            }
        }
    }
}
