import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Menu {
    id: contextMenu
    modal: true
    y: contextMenuButton.height
    width: Kirigami.Units.gridUnit * 8
    rightMargin: Kirigami.Units.smallSpacing * 3
    closePolicy: QQC2.Popup.CloseOnPressOutside

    property string containerId: ""
    property string containerName: ""
    property string containerState: ""

    signal closeContextMenu

    PlasmaComponents.MenuItem {
        visible: cfg.moveStartStopButton
        height: visible ? undefined : 0
        text: ["running", "removing", "restarting", "created"].includes(containerState) ? i18n("Stop") : i18n("Start")
        icon.name: ["running", "removing", "restarting", "created"].includes(containerState) ? Qt.resolvedUrl("../icons/dockio-stop.svg") : Qt.resolvedUrl("../icons/dockio-start.svg")
        onTriggered: {
            var socketPath = "$([ -S \"$HOME/.docker/desktop/docker.sock\" ] && echo \"$HOME/.docker/desktop/docker.sock\" || echo /var/run/docker.sock)";
            if (["running", "removing", "restarting", "created"].includes(containerState)) {
                dockerCommand.executable.exec("curl -s --unix-socket " + socketPath + " --write-out 'Response:%{http_code}' -X POST http://localhost/containers/" + containerId + "/stop");
            } else {
                dockerCommand.executable.exec("curl -s --unix-socket " + socketPath + " --write-out 'Response:%{http_code}' -X POST http://localhost/containers/" + containerId + "/start");
            }
        }
        onHoveredChanged: {
            if (!hovered) highlighted = false;
        }
    }

    PlasmaComponents.MenuItem {
        visible: cfg.moveRestartButton
        height: visible ? undefined : 0
        text: i18n("Restart")
        icon.name: Qt.resolvedUrl("../icons/dockio-refresh.svg")
        onTriggered: {
            var socketPath = "$([ -S \"$HOME/.docker/desktop/docker.sock\" ] && echo \"$HOME/.docker/desktop/docker.sock\" || echo /var/run/docker.sock)";
            dockerCommand.executable.exec("curl -s --unix-socket " + socketPath + " --write-out 'Response:%{http_code}' -X POST http://localhost/containers/" + containerId + "/restart");
        }
        onHoveredChanged: {
            if (!hovered) highlighted = false;
        }
    }

    PlasmaComponents.MenuSeparator {
        visible: cfg.moveStartStopButton || cfg.moveRestartButton
        height: visible ? undefined : 0
    }

    PlasmaComponents.Menu {
        id: execMenu
        width: Kirigami.Units.gridUnit * 7
        title: i18n("Exec")
        icon.name: Qt.resolvedUrl("../icons/dockio-term.svg")
        closePolicy: QQC2.Popup.CloseOnPressOutside

        PlasmaComponents.MenuItem {
            text: i18n("/bin/ash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} ash"`);
            }
            onHoveredChanged: {
                if (!hovered) highlighted = false;
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/bash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} bash"`);
            }
            onHoveredChanged: {
                if (!hovered) highlighted = false;
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/dash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} dash"`);
            }
            onHoveredChanged: {
                if (!hovered) highlighted = false;
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/sh")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} sh"`);
            }
            onHoveredChanged: {
                if (!hovered) highlighted = false;
            }
        }
    }

    PlasmaComponents.MenuSeparator {}

    PlasmaComponents.MenuItem {
        text: i18n("Logs")
        icon.name: Qt.resolvedUrl("../icons/dockio-logs.svg")
        onTriggered: {
            dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker logs -f ${containerId}; echo; exec $SHELL"`);
        }
        onHoveredChanged: {
            if (!hovered) highlighted = false;
        }
    }

    PlasmaComponents.MenuSeparator {
        visible: cfg.moveDeleteButton
        height: visible ? undefined : 0
    }

    PlasmaComponents.MenuItem {
        visible: cfg.moveDeleteButton
        height: visible ? undefined : 0
        text: i18n("Delete")
        icon.name: Qt.resolvedUrl("../icons/dockio-trash.svg")
        onTriggered: {
            containerListPage.createActionsDialog(containerId, containerName, "delete");
        }
        onHoveredChanged: {
            if (!hovered) highlighted = false;
        }
    }

    onClosed: {
        contextMenuButton.checked = false;
        closeContextMenu();
    }
}
