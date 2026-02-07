import QtQuick
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

KCM.SimpleKCM {
    id: appearanceConfigPage

    property alias cfg_showProgressBar : showProgressBar.checked
    property alias cfg_showStatusBar : showStatusBar.checked
    property alias cfg_moveDeleteButton : moveDeleteButton.checked
    property alias cfg_moveStartStopButton : moveStartStopButton.checked
    property alias cfg_moveRestartButton : moveRestartButton.checked
    property alias cfg_moveLogsButton : moveLogsButton.checked
    property alias cfg_moveExecButton : moveExecButton.checked
    
    ColumnLayout {
        id: infoAppearanceMessage
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: ""
            type: Kirigami.MessageType.Warning
            visible: false
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "This feature is still experimental. Enabling the refresh bar indicator may or may not impact resource usage."
            type: Kirigami.MessageType.Warning
            visible: true
        }
    }
    
    Kirigami.FormLayout {
        anchors.top: infoAppearanceMessage.bottom

        Item {
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: showProgressBar

            Kirigami.FormData.label: i18n("Enable refresh bar indicator:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        Kirigami.Heading {
            level: 3
            text: i18n("Button Placement")
        }

        PlasmaComponents.CheckBox {
            id: moveStartStopButton

            Kirigami.FormData.label: i18n("Move start/stop button to context menu:")
        }

        PlasmaComponents.CheckBox {
            id: moveRestartButton

            Kirigami.FormData.label: i18n("Move restart button to context menu:")
        }

        PlasmaComponents.CheckBox {
            id: moveLogsButton

            Kirigami.FormData.label: i18n("Move logs button to context menu:")
        }

        PlasmaComponents.CheckBox {
            id: moveExecButton

            Kirigami.FormData.label: i18n("Move exec button to context menu:")
        }

        PlasmaComponents.CheckBox {
            id: moveDeleteButton

            Kirigami.FormData.label: i18n("Move delete button to context menu:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: showStatusBar

            Kirigami.FormData.label: i18n("Enable status bar:")
        }

    }
}