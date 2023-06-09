import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Universal

import com.application.qclipboardqtquickwrapper 1.0
import com.application.localmodelloader 1.0
import com.application.sessionmanager 1.0
import com.application.settingsmanager 1.0

import "qrc:///"


Window {
    id: root
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowCloseButtonHint | Qt.Tool

    width: 320
    height: 480
    visible: true
    title: "SimplePasswordManager"

    Universal.theme: Universal.System // Universal.Light // Universal.Dark
    Universal.accent: Universal.Cobalt

    property bool m_new_document: false
    property var m_current_model: null

    function saveAppSettings() {
        settingsManager.saveSettings(
                    Qt.application.name,
                    "Settings",
                    {
                        "WindowX" : root.x,
                        "WindowY" : root.y,
                        "WindowWidth" : root.width,
                        "WindowHeight" : root.height,
                        "AlwaysOnTop" : settingsScreen.switchAlwaysOnTop.checked ? 1 : 0, // win32 registry has no boolean type; |0 or ^0 should be slower
                        "ThemeStyle" : settingsScreen.comboBoxThemeStyle.currentIndex,
                        "SliderUIFontSize" : settingsScreen.sliderUIFontSize.value,
                        "SliderTableFontSize" : settingsScreen.sliderTableFontSize.value,
                    })
    }

    function onSPMSortFilterProxyModelBeginSorting() {
        root.m_current_model = tableView.model
        tableView.model = null
        console.log("SORTING STARTED!")
        horizontalHeader.visible = false
    }

    function onSPMSortFilterProxyModelEndSorting() {
        tableView.model = root.m_current_model
        root.m_current_model = null
        console.log("SORTING ENDED!")
        horizontalHeader.visible = true
    }

    Component.onCompleted: {
        Qt.application.aboutToQuit.connect(saveAppSettings)

        let settings = settingsManager.loadSettings(Qt.application.name, "Settings")
        root.x = settings["WindowX"]
        root.y = settings["WindowY"]
        root.width = settings["WindowWidth"]
        root.height = settings["WindowHeight"]
        settingsScreen.switchAlwaysOnTop.checked = settings["AlwaysOnTop"]
        settingsScreen.comboBoxThemeStyle.currentIndex = settings["ThemeStyle"]
        settingsScreen.sliderUIFontSize.value = settings["SliderUIFontSize"]
        settingsScreen.sliderTableFontSize.value = settings["SliderTableFontSize"]
    }

    Component {
        id: delegateNonInteractiveHorizontalHeaderDelegate

        Rectangle {
            // has access to: display, edit, text, selected, current
            implicitWidth: root.width / tableView.columns
            implicitHeight: 50

            border.color: "green"
            border.width: 1
            color: Universal.background

            Label {
                text: m_display
                anchors.centerIn: parent

                font.pointSize: settingsScreen.uiFontSize

                visible: true
            }
        }
    }

    Component {
        id: delegateInteractiveHorizontalHeaderDelegate

        Rectangle {
            // has access to: display, edit, text, selected, current
            implicitWidth: root.width / tableView.columns
            implicitHeight: 50

            border.color: "green"
            border.width: 1
            color: Universal.background

            RowLayout {
                id: rowHorizontalHeader
                visible: true
                anchors.fill: parent
                anchors.leftMargin: 20
                spacing: 20

                Label {
                    id: lblHeaderCell
                    text: m_display // horizontalHeader.m_current_filter_strings[m_index] === "" ? horizontalHeader.m_current_column_names[m_index] : horizontalHeader.m_current_column_names[m_index] + ": " + horizontalHeader.m_current_filter_strings[m_index]
                    // anchors.centerIn: parent

                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    font.pointSize: settingsScreen.uiFontSize

                    // visible: true
                }

                Label {
                    id: lblSortOrder
                    text: horizontalHeader.m_current_sort_orders[m_index] === -1
                          ? ""
                          : horizontalHeader.m_current_sort_orders[m_index] === 0
                            ? "▲"
                            : "▼"
                    font.pointSize: settingsScreen.uiFontSize
                }
            }

            TextField {
                id: txtHeaderCell
                anchors.fill: parent
                text: m_text // horizontalHeader.m_current_filter_strings[m_index]
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter

                font.pointSize: settingsScreen.tableFontSize

                visible: false

                onAccepted: {
                    console.log("m_index: ", m_index)
                    console.log("txtHeaderCell.text: ", txtHeaderCell.text)

                    horizontalHeader.m_current_filter_strings[m_index] = txtHeaderCell.text
                    console.log("m_current_filter_strings:", horizontalHeader.m_current_filter_strings)

                    tableView.model.setFilterRegularExpression(horizontalHeader.m_current_filter_strings[m_index])
                    tableView.model.filterKeyColumn = m_index

                    txtHeaderCell.visible = false

                    //lblHeaderCell.text = horizontalHeader.m_current_filter_strings[index] === "" ? horizontalHeader.m_current_column_names[index] : horizontalHeader.m_current_column_names[index] + ": " + horizontalHeader.m_current_filter_strings[index]
                    // lblHeaderCell.visible = true
                    rowHorizontalHeader.visible = true
                    // lblHeaderCell.forceActiveFocus()

                    console.log("lblHeaderCell.text: ", lblHeaderCell.text)
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                               console.log("m_index: ", m_index)
                               // console.log("m_current_order: ", m_current_order)
                               // console.log("horizontalHeader.m_current_sort_orders[m_index]: ", horizontalHeader.m_current_sort_orders[m_index])
                               if(mouse.button === Qt.LeftButton) {
                                   switch(horizontalHeader.m_current_sort_orders[m_index]) {
                                       case -1: {
                                           // m_current_order = Qt.AscendingOrder // 0
                                           // horizontalHeader.current_orders[m_index] = Qt.AscendingOrder // 0
                                           horizontalHeader.m_current_sort_orders[m_index] = Qt.AscendingOrder // 0
                                           tableView.model.sort(m_index, horizontalHeader.m_current_sort_orders[m_index])
                                           console.log("horizontalHeader.m_current_sort_orders[m_index] NEW VALUE: ", horizontalHeader.m_current_sort_orders[m_index])
                                           // lblSortOrder.text = "▲"
                                           return
                                       }
                                       case 0: {
                                           // m_current_order = Qt.DescendingOrder // 1
                                           // horizontalHeader.current_orders[m_index] = Qt.DescendingOrder // 1
                                           horizontalHeader.m_current_sort_orders[m_index] = Qt.DescendingOrder // 1
                                           tableView.model.sort(m_index, horizontalHeader.m_current_sort_orders[m_index])
                                           console.log("horizontalHeader.m_current_sort_orders[m_index] NEW VALUE: ", horizontalHeader.m_current_sort_orders[m_index])
                                           // lblSortOrder.text = "▼"
                                           return
                                       }
                                       case 1: {
                                           // m_current_order = -1
                                           // horizontalHeader.current_orders[m_index] = -1
                                           horizontalHeader.m_current_sort_orders[m_index] = -1
                                           tableView.model.sort(horizontalHeader.m_current_sort_orders[m_index])
                                           console.log("horizontalHeader.m_current_sort_orders[m_index] NEW VALUE: ", horizontalHeader.m_current_sort_orders[m_index])
                                           // lblSortOrder.text = ""
                                           return
                                       }
                                   }
                               }

                               if(mouse.button === Qt.RightButton) {
                                   // lblHeaderCell.visible = false
                                   rowHorizontalHeader.visible = false

                                   txtHeaderCell.visible = true
                                   txtHeaderCell.forceActiveFocus()

                                   return
                               }
                           }
            }
        }
    }

    HorizontalHeaderView {
        id: horizontalHeader
        syncView: tableView

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        boundsBehavior: Flickable.StopAtBounds

        property var m_current_sort_orders: [-1, -1, -1]
        property var m_current_filter_strings: ["", "", ""]
        property var m_current_column_names: ["Instance", "Login", "Password"]

        delegate: Component {
            Loader {
                required property bool selected
                required property bool current
                property var m_edit: edit
                property var m_display: horizontalHeader.m_current_filter_strings[index] === "" ? horizontalHeader.m_current_column_names[index] : horizontalHeader.m_current_column_names[index] + ": " + horizontalHeader.m_current_filter_strings[index]
                property var m_text: horizontalHeader.m_current_filter_strings[index]
                // threshold index to apply delegateNonInteractiveHorizontalHeaderDelegate to last column "Password"
                // and delegateInteractiveHorizontalHeaderDelegate to all other columns (to left from "Password" column)
                property int thresholdIndex: tableView.columns - 1
                property int m_index: index
                property int m_row: row
                property int m_column: column
                property int m_current_order: -1 // horizontalHeader.m_current_sort_orders[m_index]

                sourceComponent: {
                    if(tableView.model !== null) {
                        /*
                        index increases towards columns like
                        0 1 2 3
                        condition declared in "if" below excludes last column to apply another delegate
                        */
                        if(index < thresholdIndex) {
                            return delegateInteractiveHorizontalHeaderDelegate
                        }

                        return delegateNonInteractiveHorizontalHeaderDelegate
                    }

                    return null
                }

                onLoaded: {
                    // m_display = horizontalHeader.m_current_filter_strings[index] === "" ? display : display + ": " + horizontalHeader.m_current_filter_strings[index]
                    // console.log("m_index: ", m_index)
                    // console.log("m_current_order: ", m_current_order)
                    // console.log("horizontalHeader.m_current_sort_orders NOW: ", horizontalHeader.m_current_sort_orders)
                    // horizontalHeader.m_current_sort_orders[m_index] = m_current_order
                    // console.log("horizontalHeader.m_current_sort_orders AFTER: ", horizontalHeader.m_current_sort_orders)
                }
            }
        }
    }

    TableView {
        id: tableView

        columnSpacing: 0
        rowSpacing: 0

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: horizontalHeader.bottom
        anchors.bottom: rowBottomButtons.top

        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar {}

        property var arrayColumnsWidth: []

        property int lastColumnIndex: tableView.columns - 1

        columnWidthProvider: function(column) {
            // get last column width
            if(column === lastColumnIndex) {
                // decrease total width by SUM of width of all columns except last to get last column's width
                arrayColumnsWidth[column] = tableView.width

                for(let i = 0; i < lastColumnIndex; i++) {
                    arrayColumnsWidth[column] -= arrayColumnsWidth[i]
                }

                return arrayColumnsWidth[column]
            }

            let width = explicitColumnWidth(column)

            if (width >= 0) {
                arrayColumnsWidth[column] = width;

                return width;
            }

            arrayColumnsWidth[column] = implicitColumnWidth(column)

            return arrayColumnsWidth[column]
        }

        model: null
        // model: spmSortFilterProxyModel

        selectionModel: ItemSelectionModel {
            model: tableView.model
        }

        keyNavigationEnabled: true
        pointerNavigationEnabled: true

        editTriggers: TableView.EditKeyPressed | TableView.DoubleTapped

        delegate: Component {
            Loader {
                required property bool selected
                required property bool current
                property var m_edit: edit
                // threshold index to apply delegateHiddenText to last column "Password"
                // and delegateRegularText to all other columns (to left from "Password" column)
                property int thresholdIndex: tableView.rows * (tableView.columns - 1)
                property int m_index: index
                property int m_row: row
                property int m_column: column

                sourceComponent: {
                    if(tableView.model !== null) {
                        /*
                        index increases towards rows then columns like
                        0 3 6
                        1 4 7
                        2 5 8
                        condition declared in "if" below excludes last column to apply another delegate
                        */
                        if(index < thresholdIndex) {
                            return delegateRegularText
                        }

                        return delegateHiddenText
                    }

                    return null
                }

                TableView.editDelegate: TextField {
                    anchors.fill: parent
                    text: display
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    font.pointSize: settingsScreen.tableFontSize

                    Component.onCompleted: {
                        selectAll()
                    }

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
        id: delegateRegularText

        Rectangle {
            // has access to: display, edit, text, selected, current
            id: delegateRegularTextInnerRectangle
            implicitWidth: root.width / tableView.columns
            implicitHeight: 50

            border.color: "#ccc"
            border.width: 1
            color: selected ? "gray" : Universal.background

            Label {
                id: txtCellInnerText
                text: m_edit
                anchors.centerIn: parent

                font.pointSize: settingsScreen.tableFontSize
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton

                onClicked: mouse => {
                               if(mouse.button === Qt.RightButton) {
                                   tableView.selectionModel.setCurrentIndex(
                                       tableView.index(m_row, m_column),
                                       ItemSelectionModel.Rows | ItemSelectionModel.ToggleCurrent)

                                   menuCopy.popup()
                               }
                           }

                onPressAndHold: mouse => {
                                    if (mouse.source === Qt.MouseEventNotSynthesized) {
                                        tableView.selectionModel.setCurrentIndex(
                                            tableView.index(m_row, m_column),
                                            ItemSelectionModel.Rows | ItemSelectionModel.ToggleCurrent)

                                        menuCopy.popup()
                                    }
                                }
            }
        }
    }

    Component {
        id: delegateHiddenText

        Rectangle {
            // has access to: display, edit, text, selected, current
            implicitWidth: root.width / tableView.columns
            implicitHeight: 50

            border.color: "#ccc"
            border.width: 1
            color: selected ? "gray" : Universal.background

            Label {
                id: txtCellInnerText
                text: '*'.repeat(m_edit.length)
                anchors.centerIn: parent

                font.pointSize: settingsScreen.tableFontSize
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton

                onClicked: mouse => {
                               if(mouse.button === Qt.RightButton) {
                                   tableView.selectionModel.setCurrentIndex(
                                       tableView.index(m_row, m_column),
                                       ItemSelectionModel.Rows | ItemSelectionModel.ToggleCurrent)

                                   menuCopy.popup()
                               }
                           }

                onPressAndHold: mouse => {
                                    if (mouse.source === Qt.MouseEventNotSynthesized) {
                                        tableView.selectionModel.setCurrentIndex(
                                            tableView.index(m_row, m_column),
                                            ItemSelectionModel.Rows | ItemSelectionModel.ToggleCurrent)

                                        menuCopy.popup()
                                    }
                                }
            }
        }
    }

    Menu {
        id: menuExtraButtons

        font.pointSize: settingsScreen.uiFontSize

        MenuItem {
            text: qsTr("Save")

            onTriggered: {
                if(tableView.model !== null) {
                    if(!m_new_document) {
                        localModelLoader.saveWithCredentials(
                                    tableView.model, sessionManager.username,
                                    sessionManager.password, sessionManager.currentFilePath)

                        return;
                    }

                    dialogSaveAs.open()
                }
            }
        }

        MenuItem {
            text: qsTr("Save as")

            onTriggered: {
                if(tableView.model !== null) {
                    dialogSaveAs.open()
                }
            }
        }

        MenuItem {
            text: qsTr("Close")

            onTriggered: {
                if(tableView.model !== null) {
                    dialogCloseCurrentDocument.open()
                }
            }
        }

        MenuItem {
            text: qsTr("Settings")

            onTriggered: {
                settingsScreen.dialogSettings.open()
            }
        }
    }

    Menu {
        id: menuCopy

        font.pointSize: settingsScreen.uiFontSize

        MenuItem {
            text: qsTr("Copy Login")

            onTriggered: {
                if(tableView.currentRow !== -1) {
                    clipboard.setText(
                                tableView.model.data(
                                    // logins column index, currently == 1
                                    tableView.model.index(tableView.currentRow, 1), Qt.DisplayRole))
                }
            }
        }

        MenuItem {
            text: qsTr("Copy Password")

            onTriggered: {
                if(tableView.currentRow !== -1) {
                    clipboard.setText(
                                tableView.model.data(
                                    // tableView.lastColumnIndex is passwords column and currently == 2
                                    tableView.model.index(tableView.currentRow, tableView.lastColumnIndex), Qt.DisplayRole))
                }
            }
        }
    }

    Pane {
        anchors.bottom: parent.bottom
        width: parent.width
        height: rowBottomButtons.height
    }

    RowLayout {
        id: rowBottomButtons
        anchors.bottom: parent.bottom
        width: parent.width

        visible: false

        Button {
            id: btnAddNew
            text: "+"

            Layout.alignment: Qt.AlignHCenter

            font.pointSize: settingsScreen.uiFontSize

            onClicked: {
                if(tableView.model !== null) {
                    tableView.model.insertRows(tableView.currentRow + 1, 1)
                }
            }
        }

        Dialog {
            id: dialogRemoveSelectedRecord

            anchors.centerIn: parent
            width: root.width * 0.66
            height: root.height * 0.66

            parent: Overlay.overlay

            focus: true
            modal: true
            title: qsTr("Delete record")
            standardButtons: Dialog.Yes | Dialog.No
            closePolicy: Popup.CloseOnEscape

            font.pointSize: settingsScreen.uiFontSize

            Label {
                id: txtDialogRemoveSelectedRecordInnerText
                text: qsTr("Are you sure you want to delete this record?")
            }

            onAccepted: {
                tableView.model.removeRows(tableView.currentRow, 1)
            }
        }

        Button {
            id: btnRemoveRecord
            text: "-"

            Layout.alignment: Qt.AlignHCenter

            font.pointSize: settingsScreen.uiFontSize

            onClicked: {
                if(tableView.currentRow !== -1) {
                    dialogRemoveSelectedRecord.open()
                }
            }
        }

        Button {
            id: btnCopyPasswordToClipboard
            text: qsTr("Copy")

            Layout.alignment: Qt.AlignHCenter

            font.pointSize: settingsScreen.uiFontSize

            onClicked: {
                menuCopy.popup()
            }
        }

        Dialog {
            id: dialogCloseCurrentDocument
            anchors.centerIn: parent
            width: root.width * 0.66
            height: root.height * 0.66

            parent: Overlay.overlay

            focus: true
            modal: true
            title: qsTr("Save changes reminder")
            standardButtons: Dialog.Yes | Dialog.No
            closePolicy: Popup.CloseOnEscape

            font.pointSize: settingsScreen.uiFontSize

            Label {
                id: txtDialogCloseCurrentDocumentInnerText
                text: qsTr("All unsaved changes will be lost. Are you sure want to close document?")
            }

            onAccepted: {
                localModelLoader.unloadModel(tableView, tableView.model)
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

        Button {
            text: qsTr("Menu")

            Layout.alignment: Qt.AlignHCenter

            font.pointSize: settingsScreen.uiFontSize

            onClicked: menuExtraButtons.popup()
        }
    }

    MainMenuScreen {
        id: screenMainMenu
        anchors.fill: parent

        fontSize: settingsScreen.uiFontSize

        Connections {
            target: screenMainMenu

            function onFileSelectionDone(selectedFilePath) {
                root.m_new_document = false

                sessionManager.currentFilePath = selectedFilePath

                authorizationScreen.dialog.title = qsTr("Authorization")
                authorizationScreen.dialog.open()
            }

            function onButtonOpenLocalFileClicked() {
                m_new_document = false
            }

            function onButtonCreateNewLocalFileClicked() {
                root.m_new_document = true

                localModelLoader.create(tableView, tableView.model)
            }
        }
    }

    AuthorizationScreen {
        id: authorizationScreen
        anchors.centerIn: parent

        fontSize: settingsScreen.uiFontSize

        Connections {
            target: authorizationScreen

            function onAuthorize(username, password) {
                sessionManager.username = username
                sessionManager.password = password

                if (!root.m_new_document) {
                    localModelLoader.loadWithCredentials(
                                tableView, tableView.model, sessionManager.username,
                                sessionManager.password, sessionManager.currentFilePath)

                    return;
                }

                localModelLoader.saveWithCredentials(
                            tableView.model, sessionManager.username,
                            sessionManager.password, sessionManager.currentFilePath)
            }
        }
    }

    LocalModelLoader {
        id: localModelLoader

        onModelCreated: {
            screenMainMenu.visible = false
            rowBottomButtons.visible = true

            tableView.model.beginSorting.connect(onSPMSortFilterProxyModelBeginSorting)
            tableView.model.endSorting.connect(onSPMSortFilterProxyModelEndSorting)
        }

        onModelLoaded: {
            screenMainMenu.visible = false
            rowBottomButtons.visible = true

            tableView.model.beginSorting.connect(onSPMSortFilterProxyModelBeginSorting)
            tableView.model.endSorting.connect(onSPMSortFilterProxyModelEndSorting)
        }

        onModelDestroyed: {
            screenMainMenu.visible = true
            rowBottomButtons.visible = false
        }

        onErrorOccurred: {
            errorScreen.dialogText = localModelLoader.errorMessage
            errorScreen.dialog.open()
        }
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

    ErrorScreen {
        id: errorScreen

        fontSize: settingsScreen.uiFontSize
    }

    SettingsScreen {
        id: settingsScreen
    }
}
