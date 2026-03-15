pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    // ── Theme switching ──
    property string currentTheme: "catppuccin"

    readonly property var themes: ({
        "catppuccin": {
            name: "Catppuccin Mocha",
            background: "#232332",
            text: "#b4befe",
            separator: "#313244",
            warning: "#f38ba8",
            caution: "#45475a",
            misc: "#94e2d5",
            process: "#89b4fa",
            accent: "#cba6f7",
            highlight: "#b4befe"
        },
        "rosepine": {
            name: "Ros\u00e9 Pine",
            background: "#191724",
            text: "#e0def4",
            separator: "#26233a",
            warning: "#eb6f92",
            caution: "#403d52",
            misc: "#31748f",
            process: "#9ccfd8",
            accent: "#c4a7e7",
            highlight: "#c4a7e7"
        },
        "gruvbox": {
            name: "Gruvbox Dark",
            background: "#282828",
            text: "#ebdbb2",
            separator: "#3c3836",
            warning: "#fb4934",
            caution: "#504945",
            misc: "#8ec07c",
            process: "#83a598",
            accent: "#d3869b",
            highlight: "#fabd2f"
        },
        "everforest": {
            name: "Everforest Dark",
            background: "#2d3b2d",
            text: "#d3c6aa",
            separator: "#374637",
            warning: "#e67e80",
            caution: "#414f41",
            misc: "#83c092",
            process: "#7fbbb3",
            accent: "#a7c080",
            highlight: "#a7c080"
        },
        "carbonfox": {
            name: "Carbonfox",
            background: "#161616",
            text: "#f2f4f8",
            separator: "#2a2a2a",
            warning: "#ee5396",
            caution: "#525253",
            misc: "#08bdba",
            process: "#33b1ff",
            accent: "#be95ff",
            highlight: "#78a9ff"
        },
        "gruvbox-light": {
            name: "Gruvbox Light",
            background: "#fbf1c7",
            text: "#3c3836",
            separator: "#ebdbb2",
            warning: "#cc241d",
            caution: "#d5c4a1",
            misc: "#689d6a",
            process: "#458588",
            accent: "#b16286",
            highlight: "#d79921"
        }
    })

    readonly property var _current: themes[currentTheme] || themes["catppuccin"]

    // ── Colors (reactive) ──
    readonly property color background: _current.background
    readonly property color text: _current.text
    readonly property color separator: _current.separator
    readonly property color warning: _current.warning
    readonly property color caution: _current.caution
    readonly property color misc: _current.misc
    readonly property color process: _current.process
    readonly property color accent: _current.accent
    readonly property color highlight: _current.highlight

    readonly property var themeKeys: Object.keys(themes)

    // ── Wallpaper directories ──
    readonly property var wallpaperDirs: ({
        "catppuccin": "CatppuccinMocha",
        "rosepine": "RosePine",
        "everforest": "Everforest",
        "carbonfox": "Carbonfox",
        "gruvbox": "GruvboxDark",
        "gruvbox-light": "GruvboxLight"
    })
    readonly property string wallpaperDir: "/home/honey/Pictures/Wallpapers/" + (wallpaperDirs[currentTheme] || "CatppuccinMocha")

    // ── Font settings ──
    readonly property string fontFamily: "BigBlueTerm437 Nerd Font"
    readonly property int fontSize: 12
    readonly property int fontWeight: Font.DemiBold

    // ── Dimensions ──
    readonly property int barHeight: 30
    readonly property int margin: 6
    readonly property int borderRadius: 15
    readonly property int modulePadding: 8

    // ── Persistence ──
    readonly property string _themeFile: "/home/honey/.config/quickshell/.current-theme"

    readonly property var _reader: Process {
        command: ["cat", _themeFile]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let key = data.trim();
                if (themes.hasOwnProperty(key)) currentTheme = key;
            }
        }
    }

    readonly property var _writer: Process {
        property string themeKey: ""
        command: ["sh", "-c", "echo '" + themeKey + "' > '" + _themeFile + "'"]
        running: false
    }

    readonly property var _switcher: Process {
        property string themeKey: ""
        command: ["/home/honey/.config/quickshell/scripts/switch-theme.sh", themeKey]
        running: false
    }

    function setTheme(key) {
        if (themes.hasOwnProperty(key)) {
            currentTheme = key;
            _writer.themeKey = key;
            _writer.running = true;
            _switcher.themeKey = key;
            _switcher.running = true;
        }
    }
}
