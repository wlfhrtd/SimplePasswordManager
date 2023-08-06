import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs


Item {
    property alias fontSize: m_dialogCloseApp.font.pointSize
    property alias dialog: m_dialogCloseApp

    signal quitConfirmed()

    Dialog {
        id: m_dialogCloseApp
        anchors.centerIn: parent
        width: root.width * 0.66
        height: root.height * 0.66

        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Quit app")
        standardButtons: Dialog.Yes | Dialog.No
        closePolicy: Popup.CloseOnEscape

        Label {
            id: m_lblDialogCloseAppInnerText
            text: qsTr("All unsaved changes will be lost. Are you sure want to close application?")

            width: m_dialogCloseApp.width * 0.85

            wrapMode: Text.WordWrap
        }

        onAccepted: {
            quitConfirmed()
        }
    }
}
