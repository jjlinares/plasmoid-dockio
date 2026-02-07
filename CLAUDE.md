# Plasmoid Dockio Development

## Dev Cycle

```bash
rm -rf ~/.local/share/plasma/plasmoids/org.kde.plasma.dockio && kpackagetool6 -t Plasma/Applet -i package && pkill -9 plasmashell; sleep 2; plasmashell &
```

Uninstall only: `kpackagetool6 -r org.kde.plasma.dockio`

## Architecture

- KDE Plasma 6 widget (plasmoid) for Docker container management
- Uses curl via unix socket to talk to Docker API (not docker CLI)
- Shell commands executed through `Plasma5Support.DataSource` engine

### Key Files
- `package/contents/Utils.js` - Command definitions, callbacks, Docker API interaction
- `package/contents/ui/main.qml` - Root component, timers, config properties
- `package/contents/ui/DockerCommand.qml` - DataSource wrappers for exec and container fetching
- `package/contents/ui/ContainerItemDelegate.qml` - Per-container row with toolbar buttons
- `package/contents/ui/components/ContextMenu.qml` - Dynamically created context menu
- `package/contents/config/main.xml` - Config defaults (new entries MUST be registered here)
- `package/contents/ui/config/ConfigAppearance.qml` - Appearance settings UI

## Gotchas

- **Config entries must be in main.xml** - Adding `cfg_` aliases in config QML alone won't work. The entry must also exist in `main.xml` or the Apply button won't trigger.
- **ContextMenu is dynamically created** via `Qt.createComponent`. Do NOT import `Utils.js` there - it breaks the component. Use `dockerCommand.executable.exec()` directly instead.
- **Docker socket detection** uses inline shell: `$([ -S "$HOME/.docker/desktop/docker.sock" ] && echo "$HOME/.docker/desktop/docker.sock" || echo /var/run/docker.sock)`. This runs at command time, not startup.
- **Menu submenus can't be hidden** - Setting `visible: false` or `height: 0` on a `PlasmaComponents.Menu` breaks the parent menu. Keep submenus always present; use the pattern on `MenuItem` only.
- **Restart plasmashell** after every reinstall: `pkill -9 plasmashell; sleep 2; plasmashell &`
- **Logs**: `journalctl --user -u plasma-plasmashell -n 50 --no-pager` for QML errors
- **Git remote uses SSH**: `git@github.com:jjlinares/plasmoid-dockio.git`
