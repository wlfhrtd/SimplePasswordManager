import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Controls.Universal


Item {
    signal fileSelectionDone(string selectedFilePath)
    signal buttonOpenLocalFileClicked()
    signal buttonCreateNewLocalFileClicked()

    FileDialog {
        id: dialogOpenFile
        title: qsTr("Choose file to open")
        fileMode: FileDialog.OpenFile
        nameFilters: ["MasterPassword files (*.mpdb)"]

        onAccepted: {
            if(selectedFile) {
                fileSelectionDone(selectedFile)
            }
        }
    }

    Pane {
        anchors.fill: parent

        GridLayout {
            id: grid
            columns: 2
            rows: 2

            columnSpacing: 30
            rowSpacing: 20

            width: parent.width * 0.33
            height: parent.height * 0.15
            anchors.centerIn: parent

            Button {
                id: btnOpenLocalFile

                Layout.minimumWidth: grid.width / grid.columns
                Layout.minimumHeight: grid.height / grid.rows
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rowSpan: 1
                Layout.columnSpan: 1

                text: qsTr("Open")

                onClicked: {
                    buttonOpenLocalFileClicked()

                    dialogOpenFile.open()
                }
            }

            Button {
                id: btnCreateNewLocalFile

                Layout.minimumWidth: grid.width / grid.columns
                Layout.minimumHeight: grid.height / grid.rows
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rowSpan: 1
                Layout.columnSpan: 1

                text: qsTr("Create new")

                onClicked: {
                    buttonCreateNewLocalFileClicked()
                }
            }
        }
    }
}
