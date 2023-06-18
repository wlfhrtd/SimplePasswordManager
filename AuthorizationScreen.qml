import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {
    property alias dialog: authorizationDialog

    signal authorize(string username, string password)

    Dialog {
        id: authorizationDialog

        x: (root.width - width) / 2
        y: (root.height - height) / 2
        parent: Overlay.overlay

        focus: true
        modal: true
        title: "Authorization"
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.CloseOnEscape

        ColumnLayout {
            spacing: 20
            anchors.fill: parent

            Label {
                id: lblUsername
                text: qsTr("Username")
                Layout.fillWidth: true
            }

            TextField {
                id: txtUsername
                placeholderText: qsTr("Enter username")
                Layout.fillWidth: true
                focus: true
            }

            Label {
                id: lblPassword
                text: qsTr("Password")
            }

            TextField {
                id: txtPassword
                Layout.fillWidth: true
                placeholderText: qsTr("Enter password")
                echoMode: TextInput.Password
            }
        }

        onAccepted: {
            authorize(txtUsername.text, txtPassword.text)

            txtUsername.text = ""
            txtPassword.text = ""
            txtUsername.focus = true
        }

        onRejected: {
            txtUsername.text = ""
            txtPassword.text = ""
            txtUsername.focus = true
        }
    }
}
