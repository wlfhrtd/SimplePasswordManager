import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal

Item {
    property alias switchAlwaysOnTop: m_switchAlwaysOnTop
    property alias dialogSettings: m_dialogSettings
    property alias comboBoxThemeStyle: m_comboBoxThemeStyle
    property alias sliderUIFontSize: m_sliderUIFontSize
    property alias sliderTableFontSize: m_sliderTableFontSize
    property alias uiFontSize: m_dialogSettings.m_uiFontSize
    property alias tableFontSize: m_dialogSettings.m_tableFontSize

    Dialog {
        id: m_dialogSettings
        title: qsTr("Settings")
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true

        font.pointSize: m_uiFontSize

        anchors.centerIn: parent
        width: root.width * 0.66
        height: root.height * 0.66
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        property bool alwaysOnTop: false
        property int themeStyleIndex: -1

        property real m_sliderUIFontSizeCurrentValue: 0
        property real m_sliderTableFontSizeCurrentValue: 0

        property int m_uiFontSize: 9
        property int m_tableFontSize: 9

        Component.onCompleted: {
            m_dialogSettings.alwaysOnTop = m_switchAlwaysOnTop.checked
            m_dialogSettings.themeStyleIndex = m_comboBoxThemeStyle.currentIndex

            m_dialogSettings.m_sliderUIFontSizeCurrentValue = m_sliderUIFontSize.value
            m_dialogSettings.m_sliderTableFontSizeCurrentValue = m_sliderTableFontSize.value

            m_dialogSettings.m_uiFontSize = 9 * (1 + m_sliderUIFontSize.value)
            m_dialogSettings.m_tableFontSize = 9 * (1 + m_sliderTableFontSize.value)
        }

        onAccepted: {
            m_dialogSettings.alwaysOnTop = m_switchAlwaysOnTop.checked
            m_dialogSettings.themeStyleIndex = m_comboBoxThemeStyle.currentIndex

            m_dialogSettings.m_sliderUIFontSizeCurrentValue = m_sliderUIFontSize.value
            m_dialogSettings.m_sliderTableFontSizeCurrentValue = m_sliderTableFontSize.value

            m_dialogSettings.m_uiFontSize = 9 * (1 + m_sliderUIFontSize.value)
            m_dialogSettings.m_tableFontSize = 9 * (1 + m_sliderTableFontSize.value)
        }

        onRejected: {
            m_switchAlwaysOnTop.checked = m_dialogSettings.alwaysOnTop
            m_comboBoxThemeStyle.currentIndex = m_dialogSettings.themeStyleIndex

            m_sliderUIFontSize.value = m_dialogSettings.m_sliderUIFontSizeCurrentValue
            m_sliderTableFontSize.value = m_dialogSettings.m_sliderTableFontSizeCurrentValue
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

            Label {
                text: qsTr("UI font size")
            }

            Slider {
                id: m_sliderUIFontSize
            }

            Label {
                text: qsTr("Table font size")
            }

            Slider {
                id: m_sliderTableFontSize
            }
        }
    }
}
