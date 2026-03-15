//@ pragma IconTheme Papirus

import Quickshell
import Quickshell.Io

ShellRoot {
    SmallLauncher {
        id: launcher
    }

    IpcHandler {
        target: "toggle"
        function call() { launcher.toggle(); }
    }

    IpcHandler {
        target: "open"
        function call() { launcher.open(); }
    }

    IpcHandler {
        target: "close"
        function call() { launcher.close(); }
    }
}
