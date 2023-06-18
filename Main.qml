import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import com.application.spmmodel 1.0
import com.application.qclipboardqtquickwrapper 1.0
import com.application.localmodelloader 1.0
import com.application.sessionmanager 1.0
import com.application.settingsmanager 1.0

import "qrc:///"

// TODO: get rid of m_new_document or not - no problems so far

// TODO: arrange buttons somehow; may be one with "..."
// TODO: layout & font & dark theme
Window {
    id: root
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowCloseButtonHint

    width: 320
    height: 480
    visible: true
    title: "SimplePasswordManager"

    property bool m_new_document: false

    function saveAppSettings() {
        settingsManager.saveSettings(
                    Qt.application.name,
                    "Settings",
                    {
                        "WindowX" : root.x,
                        "WindowY" : root.y,
                        "WindowWidth" : root.width,
                        "WindowHeight" : root.height,
                        "AlwaysOnTop" : checkBoxAlwaysOnTop.checked ? 1 : 0, // win32 registry has no boolean type; |0 or ^0 should be slower
                    })
    }

    Component.onCompleted: {
        Qt.application.aboutToQuit.connect(saveAppSettings)

        let settings = settingsManager.loadSettings(Qt.application.name, "Settings")
        root.x = settings["WindowX"]
        root.y = settings["WindowY"]
        root.width = settings["WindowWidth"]
        root.height = settings["WindowHeight"]
        checkBoxAlwaysOnTop.checked = settings["AlwaysOnTop"]
    }

    Dialog {
        id: dialogSettings
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

        Component.onCompleted: {
            dialogSettings.alwaysOnTop = checkBoxAlwaysOnTop.checked
        }

        onAccepted: {
            dialogSettings.alwaysOnTop = checkBoxAlwaysOnTop.checked
        }

        onRejected: {
            checkBoxAlwaysOnTop.checked = dialogSettings.alwaysOnTop
        }

        onAlwaysOnTopChanged: {
            if(!dialogSettings.alwaysOnTop) {
                root.flags ^= Qt.WindowStaysOnTopHint

                return;
            }

            root.flags |= Qt.WindowStaysOnTopHint
        }

        ColumnLayout {
            CheckBox {
                id: checkBoxAlwaysOnTop
                text: qsTr("Always On Top")
            }

            RowLayout {
                Label {
                    text: qsTr("Current window position: ")
                }

                Text {
                    text: root.x
                }

                Text {
                    text: root.y
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Current window size: ")
                }

                Text {
                    text: root.width
                }

                Text {
                    text: root.height
                }
            }
        }
    }

    Dialog {
        id: dialogError

        anchors.centerIn: parent
        width: root.width / 2
        height: root.height / 2
        parent: Overlay.overlay

        focus: true
        modal: true
        title: "Error"
        standardButtons: Dialog.Ok
        closePolicy: Popup.CloseOnEscape

        Text {
            id: txtDialogError
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter

            wrapMode: Text.WrapAnywhere
            text: ""
        }
    }

    LocalModelLoader {
        id: localModelLoader

        onErrorOccurred: {
            txtDialogError.text = localModelLoader.errorMessage
            dialogError.open()
        }
    }

    HorizontalHeaderView {
        id: horizontalHeader
        syncView: tableView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    TableView {
        id: tableView
        columnSpacing: 0
        rowSpacing: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: horizontalHeader.bottom
        anchors.bottom: rowButtons.top
        clip: true

        ScrollBar.vertical: ScrollBar {}

        model: null

        selectionModel: ItemSelectionModel {
            model: tableView.model
        }

        editTriggers: TableView.EditKeyPressed | TableView.DoubleTapped

        delegate: Component {
            Loader {
                width: 100
                height: 50

                required property bool selected
                required property bool current
                property var m_edit: edit

                sourceComponent: {
                    if(tableView.model !== null) {
                        if(index < tableView.model.rowCount()) {
                            return delegateName
                        }

                        return delegatePassword
                    }

                    return null
                }

                TableView.editDelegate: TextField {
                    anchors.fill: parent
                    text: display
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    Component.onCompleted: selectAll()

                    TableView.onCommit: {
                        edit = text // short-hand for: TableView.view.model.setData(TableView.view.index(row, column), text, Qt.EditRole)
                    }
                }

                onCurrentChanged: {
                    tableView.selectionModel.select(
                                tableView.index(tableView.currentRow, tableView.currentColumn),
                                ItemSelectionModel.Rows | ItemSelectionModel.ToggleCurrent)
                }
            }
        }
    }

    Component {
        id: delegateName
        Rectangle {
            // has access to: display, edit, text, selected, current
            id: delegateNameInnerRectangle
            implicitWidth: 100
            implicitHeight: 50
            border.color: "#ccc"
            border.width: 1

            color: selected ? "gray" : "white"

            Text {
                id: txtCellInnerText
                text: m_edit
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: delegatePassword
        Rectangle {
            // has access to: display, edit, text, selected, current
            implicitWidth: 100
            implicitHeight: 50
            border.color: "#ccc"
            border.width: 1

            color: selected ? "gray" : "white"

            Text {
                id: txtCellInnerText
                text: '*'.repeat(m_edit.length)
                anchors.centerIn: parent
            }
        }
    }

    GridLayout {
        id: rowButtons
        anchors.bottom: parent.bottom
        width: parent.width

        columns: 3

        RoundButton {
            id: btnAddNew
            text: "+"

            onClicked: {
                if(tableView.model !== null) {
                    tableView.model.insertRows(tableView.currentRow + 1, 1)
                }
            }
        }

        RoundButton {
            id: btnRemoveRecord
            text: "-"

            onClicked: {
                if(tableView.currentRow !== -1) {
                    tableView.model.removeRows(tableView.currentRow, 1)
                }
            }
        }

        RoundButton {
            id: btnCopyPasswordToClipboard
            text: qsTr("Copy")

            onClicked: {
                if(tableView.currentRow !== -1) {
                    clipboard.setText(
                                tableView.model.data(tableView.model.index(tableView.currentRow, 1), Qt.DisplayRole)) // 1 is passwords column
                }
            }
        }

        RoundButton {
            id: btnSaveToLocalFile
            text: qsTr("Save")

            onClicked: {
                if(tableView.model !== null) {
                    if(tableView.model.rowCount() !== 0 && !m_new_document) {
                        localModelLoader.saveWithCredentials(
                                    tableView.model, sessionManager.username, sessionManager.password, sessionManager.currentFilePath)

                        return;
                    }

                    if (tableView.model.rowCount() !== 0) {
                        dialogSaveAs.open()
                    }
                }
            }
        }

        FileDialog {
            id: dialogOpenFile
            title: qsTr("Choose file to open")
            fileMode: FileDialog.OpenFile
            nameFilters: ["MasterPassword files (*.mpdb)"]

            onAccepted: {
                if (selectedFile) {
                    root.m_new_document = false

                    sessionManager.currentFilePath = selectedFile

                    authorizationScreen.dialog.open()
                }
            }
        }

        RoundButton {
            id: btnOpenLocalFile
            text: qsTr("Open")

            onClicked: {
                m_new_document = false

                dialogOpenFile.open()
            }
        }

        RoundButton {
            id: btnNewLocalFile
            text: qsTr("Create new")

            onClicked: {
                root.m_new_document = true

                localModelLoader.create(tableView, tableView.model)
            }
        }

        FileDialog {
            id: dialogSaveAs
            title: qsTr("Save as")
            fileMode: FileDialog.SaveFile
            nameFilters: ["MasterPassword files (*.mpdb)"]

            onAccepted: {
                if(selectedFile) {
                    root.m_new_document = true

                    sessionManager.currentFilePath = selectedFile

                    authorizationScreen.dialog.title = qsTr("Enter login/password for new file: ")
                    authorizationScreen.dialog.open()
                }
            }
        }

        RoundButton {
            id: btnSaveAs
            text: qsTr("Save as")

            onClicked: {
                if(tableView.model !== null) {
                    dialogSaveAs.open()
                }
            }
        }

        Dialog {
            id: dialogCloseCurrentDocument

            x: (root.width - width) / 2
            y: (root.height - height) / 2
            parent: Overlay.overlay

            focus: true
            modal: true
            title: qsTr("Save changes reminder")
            standardButtons: Dialog.Ok | Dialog.Cancel
            closePolicy: Popup.CloseOnEscape

            Text {
                id: txtDialogCloseCurrentDocumentInnerText
                text: qsTr("All unsaved changes will be lost. Are you sure want to close document?")
            }

            onAccepted: {
                localModelLoader.unloadModel(tableView, tableView.model)
            }
        }

        RoundButton {
            id: btnCloseCurrentDocument
            text: qsTr("Close")

            onClicked: {
                dialogCloseCurrentDocument.open()
            }
        }

        RoundButton {
            id: btnSettingsDialog
            text: qsTr("Settings")

            onClicked: {
                dialogSettings.open()
            }
        }
    }

    Connections {
        target: authorizationScreen

        function onAuthorize(username, password) {
            sessionManager.username = username
            sessionManager.password = password

            if (!root.m_new_document) {
                localModelLoader.loadWithCredentials(
                            tableView, tableView.model, sessionManager.username, sessionManager.password, sessionManager.currentFilePath)

                return;
            }

            localModelLoader.saveWithCredentials(
                        tableView.model, sessionManager.username, sessionManager.password, sessionManager.currentFilePath)
        }
    }

    AuthorizationScreen {
        id: authorizationScreen
        anchors.centerIn: parent
    }

    QClipboardQtQuickWrapper {
        id: clipboard
    }

    SessionManager {
        id: sessionManager
    }

    SettingsManager {
        id: settingsManager
    }
}
