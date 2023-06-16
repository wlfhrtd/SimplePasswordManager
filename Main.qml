import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import com.application.spmmodel 1.0
import com.application.qclipboardqtquickwrapper 1.0
import com.application.localmodelloader 1.0
import com.application.sessionmanager 1.0

import "qrc:///"

// TODO: get rid of m_new_document or not - no problems so far
// TODO: get rid of QuaZip and zip at all; keep login/pass just for AES, keep qCompress
Window {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("SimplePasswordManager")

    // property string m_selected_file: ""
    property bool m_new_document: false

    QClipboardQtQuickWrapper {
        id: clipboard
    }

    LocalModelLoader {
        id: localModelLoader
    }
    // prolly should store already hashed data
    SessionManager {
        id: sessionManager
    }

    HorizontalHeaderView {
        id: horizontalHeader
        syncView: tableView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    // https://stackoverflow.com/questions/31985972/different-delegates-for-qml-listview @Mousavi
    // https://doc.qt.io/qt-6/qml-qtquick-loader.html#using-a-loader-within-a-view-delegate


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
        //model: SPMModel {}

        selectionModel: ItemSelectionModel {
            model: tableView.model
        }
// editTriggers: TableView.AnyKeyPressed
        delegate: Component {
            Loader {
                width: 100
                height: 50

                required property bool selected
                property var m_edit: edit

                sourceComponent: {
                    if(index < tableView.model.rowCount()) {
                        return delegateName
                    }

                    return delegatePassword
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

                //onLoaded: tableView.edit(TableView.view.index(0, 0))
            }


        }

        SelectionRectangle {
            target: tableView
            selectionMode: SelectionRectangle.PressAndHold
        }
    }

    Component {
        id: delegateName
        Rectangle {
            // has access to: display, edit, text
            implicitWidth: 100
            implicitHeight: 50
            border.color: "#ccc"
            border.width: 1

            // required property bool selected
            //required property bool current

            color: selected ? "gray" : "white"

            Text {
                id: txtCellInnerText
                text: m_edit
                anchors.centerIn: parent
            }

//            TableView.editDelegate: TextField {
//                anchors.fill: parent
//                text: display
//                horizontalAlignment: TextInput.AlignHCenter
//                verticalAlignment: TextInput.AlignVCenter

//                Component.onCompleted: selectAll()

//                TableView.onCommit: {
//                    edit = text // short-hand for: TableView.view.model.setData(TableView.view.index(row, column), text, Qt.EditRole)
//                }
//            }
        }
    }

    Component {
        id: delegatePassword
        Rectangle {
            // has access to: display, edit, text
            implicitWidth: 100
            implicitHeight: 50
            border.color: "#ccc"
            border.width: 1

            // required property bool selected
            //required property bool current

            color: selected ? "gray" : "white"

            Text {
                id: txtCellInnerText
                text: '*'.repeat(m_edit.length)
                anchors.centerIn: parent
            }

//            TableView.editDelegate: TextField {
//                anchors.fill: parent
//                text: display
//                horizontalAlignment: TextInput.AlignHCenter
//                verticalAlignment: TextInput.AlignVCenter

//                Component.onCompleted: selectAll()

//                TableView.onCommit: {
//                    edit = text // short-hand for: TableView.view.model.setData(TableView.view.index(row, column), text, Qt.EditRole)
//                }
//            }
        }
    }

    RowLayout {
        id: rowButtons
        anchors.bottom: parent.bottom

        RoundButton {
            id: btnAddNew
            text: "+"

            onClicked: {
                tableView.model.insertRows(tableView.currentRow + 1, 1)
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
            text: "Copy"

            onClicked: {
                if(tableView.currentRow !== -1) {
                    console.log(tableView.model.data(tableView.model.index(tableView.currentRow, tableView.currentColumn), Qt.DisplayRole))
                    clipboard.setText(tableView.model.data(tableView.model.index(tableView.currentRow, 1), Qt.DisplayRole)) // 1 is passwords column
                }
            }
        }

        RoundButton {
            id: btnSaveToLocalFile
            text: "Save"

            onClicked: {
                if(tableView.model.rowCount() !== 0 && !m_new_document) {
                    // localModelLoader.save(tableView.model)
                    localModelLoader.saveWithCredentials(
                                tableView.model, sessionManager.username, sessionManager.password, sessionManager.currentFilePath)

                    return;
                }

                if (tableView.model.rowCount() !== 0) {
                    dialogSaveAs.open()
                }
            }
        }

        //        RoundButton {
        //            id: btnLoadFromLocalFile
        //            text: "Load"

        //            onClicked: {
        //                // tableView.model = localModelLoader.load(tableView, tableView.model) // explicitly loaded from C++ objects become JS GC managed
        //                localModelLoader.load(tableView, tableView.model) // C++ managed; delete detached models explicitly
        //                // tableView.model.destroy() // shouldn't work on objects which still have parent
        //            }
        //        }

        FileDialog {
            id: dialogOpenFile
            title: "Choose file to open"
            fileMode: FileDialog.OpenFile
            nameFilters: ["MasterPassword files (*.mpdb)"]

            onAccepted: {
                if (selectedFile) {
                    console.log(selectedFile)
                    //                    root.m_selected_file = selectedFile
                    root.m_new_document = false

                    sessionManager.currentFilePath = selectedFile

                    authorizationScreen.dialog.open()
                }
            }
        }

        RoundButton {
            id: btnOpenLocalFile
            text: "Open"

            onClicked: {
                m_new_document = false

                dialogOpenFile.open()
            }
        }

        RoundButton {
            id: btnNewLocalFile
            text: "Create new"

            onClicked: {
                // dialogNewFile.open()
                root.m_new_document = true

                localModelLoader.create(tableView, tableView.model)
            }
        }

        FileDialog {
            id: dialogSaveAs
            title: "Save as"
            fileMode: FileDialog.SaveFile
            nameFilters: ["MasterPassword files (*.mpdb)"]

            onAccepted: {
                if(selectedFile) {
                    if(tableView.model.rowCount() !== 0) {
                        console.log(selectedFile)
                        //                        root.m_selected_file = selectedFile
                        root.m_new_document = true

                        sessionManager.currentFilePath = selectedFile

                        authorizationScreen.dialog.open()
                    }
                }
            }
        }

        RoundButton {
            id: btnSaveAs
            text: qsTr("Save as")

            onClicked: {
                dialogSaveAs.open()
            }
        }

        Dialog {
            id: dialogCloseCurrentDocument

            x: (root.width - width) / 2
            y: (root.height - height) / 2
            parent: Overlay.overlay

            focus: true
            modal: true
            title: "Save changes reminder"
            standardButtons: Dialog.Ok | Dialog.Cancel
            closePolicy: Popup.CloseOnEscape

            Text {
                id: txtDialogCloseCurrentDocumentInnerText
                text: "All unsaved changes will be lost. Are you sure want to close document?"
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
    }

    Connections {
        target: authorizationScreen
        // more like onCredentialsAccepted~~~~ to reuse just changing title
        function onAuthorize(username, password) {
            //            root.m_current_username = username
            //            root.m_current_password = password
            // localModelLoader.loadWithCredentials(tableView, tableView.model, username, password, root.m_selected_file)
            // pass model, username, password, filename to loader
            //localModelLoader.saveWithCredentials(tableView.model, ???username, ???password, selectedFile)

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

    //    Popup {
    //        id: authorizationPopup
    //        anchors.centerIn: parent
    //        modal: true
    //        focus: true
    //        closePolicy: Popup.CloseOnEscape

    //        Label {
    //            id: lblAuthorizationStatus
    //            anchors.centerIn: parent
    //            text: ""
    //        }
    //    }

    AuthorizationScreen {
        id: authorizationScreen
        anchors.centerIn: parent
    }
}
