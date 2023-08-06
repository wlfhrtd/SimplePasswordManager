import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    property alias fontSize: m_dialogCloseCurrentDocument.font.pointSize
    property alias dialog: m_dialogCloseCurrentDocument

    signal closeCurrentDocumentConfirmed()

    Dialog {
        id: m_dialogCloseCurrentDocument
        anchors.centerIn: parent
        width: root.width * 0.66
        height: root.height * 0.66

        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Save changes reminder")
        standardButtons: Dialog.Yes | Dialog.No
        closePolicy: Popup.CloseOnEscape

        Label {
            id: m_lblDialogCloseCurrentDocumentInnerText
            text: qsTr("All unsaved changes will be lost. Are you sure want to close document?")

            width: m_dialogCloseCurrentDocument.width * 0.85

            wrapMode: Text.WordWrap
        }

        onAccepted: {
            closeCurrentDocumentConfirmed()
        }
    }
}
