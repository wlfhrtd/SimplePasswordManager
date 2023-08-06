import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    property alias fontSize: m_dialogRemoveSelectedRecord.font.pointSize
    property alias dialog: m_dialogRemoveSelectedRecord

    signal removeRecordConfirmed()

    Dialog {
        id: m_dialogRemoveSelectedRecord

        anchors.centerIn: parent
        width: root.width * 0.66
        height: root.height * 0.66

        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Delete record")
        standardButtons: Dialog.Yes | Dialog.No
        closePolicy: Popup.CloseOnEscape

        Label {
            id: m_lblDialogRemoveSelectedRecordInnerText
            text: qsTr("Are you sure you want to delete this record?")

            width: m_dialogRemoveSelectedRecord.width * 0.85

            wrapMode: Text.WordWrap
        }

        onAccepted: {
            removeRecordConfirmed()
        }
    }
}
