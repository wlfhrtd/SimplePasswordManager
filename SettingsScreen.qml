import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal

Item {
    property alias switchAlwaysOnTop: m_switchAlwaysOnTop
    property alias dialogSettings: m_dialogSettings
    property alias comboBoxThemeStyle: m_comboBoxThemeStyle

    Dialog {
        id: m_dialogSettings
        title: qsTr("Settings")
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true

        anchors.centerIn: parent
        width: root.width / 2
        height: root.height / 2
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        property bool alwaysOnTop: false
        property int themeStyleIndex: -1

        Component.onCompleted: {
            m_dialogSettings.alwaysOnTop = m_switchAlwaysOnTop.checked
            m_dialogSettings.themeStyleIndex = m_comboBoxThemeStyle.currentIndex
        }

        onAccepted: {
            m_dialogSettings.alwaysOnTop = m_switchAlwaysOnTop.checked
            m_dialogSettings.themeStyleIndex = m_comboBoxThemeStyle.currentIndex
        }

        onRejected: {
            m_switchAlwaysOnTop.checked = m_dialogSettings.alwaysOnTop
            m_comboBoxThemeStyle.currentIndex = m_dialogSettings.themeStyleIndex
        }

        onAlwaysOnTopChanged: {
            if(!m_dialogSettings.alwaysOnTop) {
                root.flags ^= Qt.WindowStaysOnTopHint

                return;
            }

            root.flags |= Qt.WindowStaysOnTopHint
        }

        onThemeStyleIndexChanged: {
            root.Universal.theme = m_comboBoxThemeStyle.valueAt(m_dialogSettings.themeStyleIndex)
        }

        ColumnLayout {
            Switch {
                id: m_switchAlwaysOnTop
                text: qsTr("Always On Top")
            }

            RowLayout {
                Label {
                    text: qsTr("Current window position: ")
                }

                Label {
                    text: root.x
                }

                Label {
                    text: root.y
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Current window size: ")
                }

                Label {
                    text: root.width
                }

                Label {
                    text: root.height
                }
            }

            Label {
                text: qsTr("Theme style")
            }

            ComboBox {
                id: m_comboBoxThemeStyle

                textRole: "text"
                valueRole: "value"

                model: ListModel {
                    ListElement {
                        text: "Light"
                        value: Universal.Light
                    }
                    ListElement {
                        text: "Dark"
                        value: Universal.Dark
                    }
                    ListElement {
                        text: "System"
                        value: Universal.System
                    }
                }
            }
        }
    }
}
