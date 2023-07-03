import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal


Item {
    property alias dialog: m_authorizationDialog

    signal authorize(string username, string password)

    Dialog {
        id: m_authorizationDialog

        anchors.centerIn: parent
        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Authorization")
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.CloseOnEscape

        ColumnLayout {
            spacing: 20
            anchors.fill: parent

            Label {
                id: m_lblUsername
                text: qsTr("Username")
                Layout.fillWidth: true
            }

            TextField {
                id: m_txtUsername
                placeholderText: qsTr("Enter username")
                Layout.fillWidth: true
                focus: true
            }

            Label {
                id: m_lblPassword
                text: qsTr("Password")
            }

            TextField {
                id: m_txtPassword
                Layout.fillWidth: true
                placeholderText: qsTr("Enter password")
                echoMode: TextInput.Password
            }

            Keys.onEnterPressed: {
                m_authorizationDialog.accept()
            }

            Keys.onReturnPressed: {
                m_authorizationDialog.accept()
            }
        }

        onAccepted: {
            authorize(m_txtUsername.text, m_txtPassword.text)

            m_txtUsername.text = ""
            m_txtPassword.text = ""
            m_txtUsername.focus = true
        }

        onRejected: {
            m_txtUsername.text = ""
            m_txtPassword.text = ""
            m_txtUsername.focus = true
        }       
    }    
}
