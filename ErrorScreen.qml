import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Controls.Universal


Item {
    property alias dialog: m_dialogError
    property alias dialogText: m_txtDialogError.text
    property alias fontSize: m_dialogError.font.pointSize

    Dialog {
        id: m_dialogError

        anchors.centerIn: parent
        width: root.width * 0.66
        height: root.height * 0.66

        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Error")

        closePolicy: Popup.CloseOnEscape

        ColumnLayout {
            spacing: 20
            anchors.fill: parent

            Label {
                id: m_txtDialogError

                Layout.fillWidth: true

                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAnywhere
                text: ""
            }

            Button {
                id: closeButton

                Layout.fillWidth: true

                focus: true

                text: "OK"

                onClicked: m_dialogError.accept()
            }

            Keys.onEnterPressed: m_dialogError.accept()
            Keys.onReturnPressed: m_dialogError.accept()
        }
    }
}
