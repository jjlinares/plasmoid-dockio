import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

ColumnLayout{
    id: containerListPage
    spacing: 0

    property alias view: containerListView
    property alias model: containerListView.model
    property string sortBy: "ContainerName"
    property bool ascending: true
    property var stateFilters: []
    onStateFiltersChanged: stateFilterModel.invalidateFilter()
    property var imageFilters: []
    onImageFiltersChanged: imageFilterModel.invalidateFilter()
    property var projectFilters: []
    onProjectFiltersChanged: projectFilterModel.invalidateFilter()

    function uniqueImages() {
        let images = []
        for (let i = 0; i < containerModel.count; i++) {
            let img = containerModel.get(i).containerImage
            if (img && !images.includes(img)) images.push(img)
        }
        return images.sort()
    }

    function uniqueProjects() {
        let projects = []
        let hasStandalone = false
        for (let i = 0; i < containerModel.count; i++) {
            let p = containerModel.get(i).containerProject
            if (!p) hasStandalone = true
            else if (!projects.includes(p)) projects.push(p)
        }
        projects.sort()
        if (hasStandalone) projects.unshift("")
        return projects
    }
    property var actionsDialog: null

    function createActionsDialog(containerId, containerName, action) {
        if (actionsDialog === null) {
            var component = Qt.createComponent("./components/ActionsDialog.qml");
            actionsDialog = component.createObject(parent);
            actionsDialog.containerId = containerId;
            actionsDialog.containerName = containerName;
            actionsDialog.action = action;
            if (action === "delete") {
                actionsDialog.standardButtons = QQC2.Dialog.Yes | QQC2.Dialog.No;
            }
            if (actionsDialog !== null) {
                actionsDialog.closeActionsDialog.connect(destroyActionsDialog);
                actionsDialog.doActions.connect(doActionsHandler);
            }
        }
    }

    function destroyActionsDialog() {
        if (actionsDialog !== null) {
            actionsDialog.destroy();
            actionsDialog = null;
        }
    }

    function doActionsHandler(containerId, containerName, action) {
        if (action === "delete") {
            Utils.commands["deleteContainer"].run(containerId, containerName);
        }
    }

    Connections {
        target: main
        function onExpandedChanged() {
            if (main.expanded) {
                destroyActionsDialog();
            } else if (!main.expanded) {
                destroyActionsDialog();
            }
        }
    }

    property var header: PlasmaExtras.PlasmoidHeading {

        contentItem: RowLayout {
            spacing: 0
            
            enabled: containerModel.count > 0

            PlasmaComponents.ToolButton {
                id: sortButton
                property var sortable: [["containerName", "Container Name", "view-sort-ascending-name", "view-sort-descending-name"]]
                icon.name: sortButton.sortable[0][ascending ? 2 : 3]
                onClicked: {
                    ascending = !ascending
                    var sortBy = sortable[0][0]
                    if (filterModel) {
                        filterModel.sortRoleName = sortBy
                        filterModel.sortOrder = ascending ? Qt.AscendingOrder : Qt.DescendingOrder
                    }
                }

                display: QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip {
                    text: i18n(sortButton.sortable[0][1] + (ascending ? "" : "(Descending)"))
                }
            }

            PlasmaComponents.ToolButton {
                id: stateFilterButton
                icon.name: "flag"
                display: QQC2.AbstractButton.IconOnly
                checked: stateFilters.length > 0
                onClicked: stateFilterMenu.open()

                readonly property var allStates: ["running", "exited", "paused", "restarting"]
                function toggleState(state) {
                    let f = stateFilters.slice()
                    let idx = f.indexOf(state)
                    if (idx >= 0) f.splice(idx, 1); else f.push(state)
                    stateFilters = f.length === allStates.length ? [] : f
                }

                PlasmaComponents.ToolTip {
                    text: stateFilters.length === 0 ? i18n("Filter by state") : i18n("Filter: %1", stateFilters.join(", "))
                }

                PlasmaComponents.Menu {
                    id: stateFilterMenu
                    y: stateFilterButton.height
                    closePolicy: QQC2.Popup.CloseOnPressOutside

                    PlasmaComponents.MenuItem {
                        text: i18n("All")
                        checkable: true
                        checked: stateFilters.length === 0
                        onClicked: stateFilters = []
                    }
                    PlasmaComponents.MenuItem {
                        text: i18n("Running")
                        checkable: true
                        checked: stateFilters.includes("running")
                        onClicked: stateFilterButton.toggleState("running")
                    }
                    PlasmaComponents.MenuItem {
                        text: i18n("Exited")
                        checkable: true
                        checked: stateFilters.includes("exited")
                        onClicked: stateFilterButton.toggleState("exited")
                    }
                    PlasmaComponents.MenuItem {
                        text: i18n("Paused")
                        checkable: true
                        checked: stateFilters.includes("paused")
                        onClicked: stateFilterButton.toggleState("paused")
                    }
                    PlasmaComponents.MenuItem {
                        text: i18n("Restarting")
                        checkable: true
                        checked: stateFilters.includes("restarting")
                        onClicked: stateFilterButton.toggleState("restarting")
                    }
                }
            }

            PlasmaComponents.ToolButton {
                id: imageFilterButton
                icon.name: "filename-title-amarok"
                display: QQC2.AbstractButton.IconOnly
                checked: imageFilters.length > 0
                onClicked: {
                    imageFilterMenu.imageList = uniqueImages()
                    imageFilterMenu.open()
                }

                function toggleImage(img) {
                    let f = imageFilters.slice()
                    let idx = f.indexOf(img)
                    if (idx >= 0) f.splice(idx, 1); else f.push(img)
                    let all = uniqueImages()
                    imageFilters = f.length === all.length ? [] : f
                }

                PlasmaComponents.ToolTip {
                    text: imageFilters.length === 0 ? i18n("Filter by image") : i18n("Image: %1", imageFilters.join(", "))
                }

                PlasmaComponents.Menu {
                    id: imageFilterMenu
                    y: imageFilterButton.height
                    closePolicy: QQC2.Popup.CloseOnPressOutside

                    property var imageList: []

                    PlasmaComponents.MenuItem {
                        text: i18n("All")
                        checkable: true
                        checked: imageFilters.length === 0
                        onClicked: imageFilters = []
                    }

                    PlasmaComponents.MenuSeparator {}

                    Repeater {
                        model: imageFilterMenu.imageList
                        delegate: PlasmaComponents.MenuItem {
                            text: modelData
                            checkable: true
                            checked: imageFilters.includes(modelData)
                            onClicked: imageFilterButton.toggleImage(modelData)
                        }
                    }
                }
            }

            PlasmaComponents.ToolButton {
                id: projectFilterButton
                icon.name: "object-group"
                display: QQC2.AbstractButton.IconOnly
                checked: projectFilters.length > 0
                visible: uniqueProjects().length > 1
                onClicked: {
                    projectFilterMenu.projectList = uniqueProjects()
                    projectFilterMenu.open()
                }

                function toggleProject(proj) {
                    let f = projectFilters.slice()
                    let idx = f.indexOf(proj)
                    if (idx >= 0) f.splice(idx, 1); else f.push(proj)
                    let all = uniqueProjects()
                    projectFilters = f.length === all.length ? [] : f
                }

                PlasmaComponents.ToolTip {
                    text: projectFilters.length === 0 ? i18n("Filter by compose project") : i18n("Project: %1", projectFilters.map(p => p || "Standalone").join(", "))
                }

                PlasmaComponents.Menu {
                    id: projectFilterMenu
                    y: projectFilterButton.height
                    closePolicy: QQC2.Popup.CloseOnPressOutside

                    property var projectList: []

                    PlasmaComponents.MenuItem {
                        text: i18n("All")
                        checkable: true
                        checked: projectFilters.length === 0
                        onClicked: projectFilters = []
                    }

                    PlasmaComponents.MenuItem {
                        text: i18n("Standalone")
                        checkable: true
                        checked: projectFilters.includes("")
                        onClicked: projectFilterButton.toggleProject("")
                    }

                    PlasmaComponents.MenuSeparator {}

                    Repeater {
                        model: projectFilterMenu.projectList.filter(p => p !== "")
                        delegate: PlasmaComponents.MenuItem {
                            text: modelData
                            checkable: true
                            checked: projectFilters.includes(modelData)
                            onClicked: projectFilterButton.toggleProject(modelData)
                        }
                    }
                }
            }

            PlasmaExtras.SearchField {
                id: filter
                Layout.fillWidth: true
                // focus: !Kirigami.InputMethod.willShowOnActive
            }
            
            PlasmaComponents.ToolButton {
                text: i18n("Refresh")
                icon.name: Qt.resolvedUrl("icons/dockio-refresh.svg")
                onClicked: {
                    dockerCommand.fetchContainers.get();
                    fetchTimer.restart();
                    startProgressBar();
                }
                display: QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip{ text: parent.text }
            }
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: stateFilterModel
        sourceModel: containerModel
        filterRoleName: "containerState"
        filterRowCallback: function(sourceRow, sourceParent) {
            if (stateFilters.length === 0) return true
            let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole)
            return stateFilters.includes(value)
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: imageFilterModel
        sourceModel: stateFilterModel
        filterRoleName: "containerImage"
        filterRowCallback: function(sourceRow, sourceParent) {
            if (imageFilters.length === 0) return true
            let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole)
            return imageFilters.includes(value)
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: projectFilterModel
        sourceModel: imageFilterModel
        filterRoleName: "containerProject"
        filterRowCallback: function(sourceRow, sourceParent) {
            if (projectFilters.length === 0) return true
            let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole)
            return projectFilters.includes(value)
        }
    }

    model: KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: projectFilterModel
        filterRoleName: "containerName"
        filterRegularExpression: RegExp(filter.text, "i")
        filterCaseSensitivity: Qt.CaseInsensitive
        sortCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: sortBy
        recursiveFilteringEnabled: true
        sortOrder: ascending ? Qt.AscendingOrder : Qt.DescendingOrder
    }

    Kirigami.InlineMessage {
        id: errorMessage
        width: parent.width
        type: Kirigami.MessageType.Error
        icon.name: Qt.resolvedUrl("icons/dockio-error.svg")
        text: main.error
        visible: main.error != ""
        actions: Kirigami.Action {
            text: i18nc("@action:button","Clear")
            onTriggered: {
                error = ""
                Utils.initState();
            }
        }
    }

    // Experimental: Progress Bar
    PlasmaComponents.ProgressBar {
        id: progressBar
        visible: cfg.showProgressBar && dockerEnable && containerListView.count !== 0
        topInset: 0
        topPadding: 0
        bottomInset: 0
        bottomPadding: 0
        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
        from: 0
        to: 100
        value: 0
        indeterminate: false

        SequentialAnimation on value {
            id: progressBarAnimation
            running: cfg.showProgressBar && dockerEnable && main.expanded
            loops: Animation.Infinite

            NumberAnimation {
                from: 0
                to: 100
                duration: cfg.fetchContainerInterval * 1000
                easing.type: Easing.Linear
            }
            PauseAnimation {
                duration: 0
            }
        }
    }

    PlasmaComponents.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        background: null

        contentItem: ListView {
            id: containerListView

            model: containerModel
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            currentIndex: -1
            reuseItems: true

            Connections {
                target: main
                function onExpandedChanged() {
                    if (main.expanded) {
                        containerListView.currentIndex = -1
                        containerListView.positionViewAtBeginning()
                    }
                }
            }

            delegate: ContainerItemDelegate {
                width: containerListView.width
            }

            Kirigami.PlaceholderMessage {
                anchors.centerIn: parent
                visible: containerListView.count === 0
                text: {
                    if (filter.text !== "" || stateFilters.length > 0 || imageFilters.length > 0 || projectFilters.length > 0) return "No results.";
                    else if (error !== "") return "Some error occurred.";
                    else return "Start your docker!";
                    }
                icon.name: {
                    if (filter.text !== "" || stateFilters.length > 0 || imageFilters.length > 0 || projectFilters.length > 0) return Qt.resolvedUrl("icons/dockio-cube.svg");
                    else if (error !== "") return Qt.resolvedUrl("icons/dockio-error.svg");
                    else return Qt.resolvedUrl("icons/dockio-icon.svg");
                }

            }
        }
    }

    KSvg.SvgItem {
        Layout.fillWidth: true
        Layout.topMargin: 0
        Layout.bottomMargin: 0
        visible: cfg.showStatusBar && dockerEnable
        imagePath: "widgets/line"
        elementId: "horizontal-line"
    }

    Rectangle {
        id: mainStatusBar
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        visible: cfg.showStatusBar && dockerEnable
        height: mainStatusBarContent.height
        color: "transparent"
        bottomLeftRadius: 5
        bottomRightRadius: 5

        RowLayout {
            id: mainStatusBarContent
            anchors.verticalCenter: parent.verticalCenter
            ColumnLayout {
            spacing: 1

                PlasmaComponents.Label {
                    text: i18n("Images: ") + dockerCommand.infoArray.Images
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }

                PlasmaComponents.Label {
                    text: i18n("Containers: ") + dockerCommand.infoArray.Containers
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }

            ColumnLayout {
                spacing: 1

                Item { 
                    Layout.fillHeight: true
                }

                PlasmaComponents.Label {
                    text: i18n("Running: ") + dockerCommand.infoArray.ContainersRunning
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }

            ColumnLayout {
                spacing: 1

                Item { 
                    Layout.fillHeight: true
                }

                PlasmaComponents.Label {
                    text: i18n("Stopped: ") + dockerCommand.infoArray.ContainersStopped
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }
        }
    }

    Connections {
        target: main
        function onStartProgressBar() {
            progressBarAnimation.stop(); // Experimental: Stop progress bar animation
            progressBar.value = 0 // Experimental: Reset progress bar value to 0
            progressBarAnimation.start(); // Experimental: Start progress bar animation
            }
        function onStopProgressBar() {
            progressBarAnimation.stop();
            progressBar.value = 0 
        }
    }
}