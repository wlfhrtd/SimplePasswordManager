import QtQuick
import QtQuick.Controls

Item {
    property alias fontSize: m_menuCopy.font.pointSize
    property alias menu: m_menuCopy

    signal itemCopyLoginTriggered()
    signal itemCopyPasswordTriggered()

    Menu {
        id: m_menuCopy

        MenuItem {
            text: qsTr("Copy Login")

            onTriggered: {
                itemCopyLoginTriggered()
            }
        }

        MenuItem {
            text: qsTr("Copy Password")

            onTriggered: {
                itemCopyPasswordTriggered()
            }
        }
    }
}
