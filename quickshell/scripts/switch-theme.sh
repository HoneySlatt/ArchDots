#!/usr/bin/env bash
# Switch Arch theme — kitty, yazi, neovim, hyprland, gtk, fastfetch

THEME="${1:-catppuccin}"

# ── Color palettes ──────────────────────────────────────────────────────────
declare -A C
case "$THEME" in
  catppuccin)
    C[name]="Catppuccin Mocha"
    C[base]="#1e1e2e" C[mantle]="#181825" C[crust]="#11111b"
    C[surface0]="#313244" C[surface1]="#45475a" C[surface2]="#585b70"
    C[overlay0]="#6c7086" C[overlay1]="#7f849c"
    C[text]="#cdd6f4" C[subtext1]="#bac2de" C[subtext0]="#a6adc8"
    C[red]="#f38ba8" C[maroon]="#eba0ac" C[rosewater]="#f5e0dc" C[flamingo]="#f2cdcd"
    C[pink]="#f5c2e7" C[mauve]="#cba6f7" C[lavender]="#b4befe"
    C[blue]="#89b4fa" C[sapphire]="#74c7ec" C[sky]="#89dceb"
    C[teal]="#94e2d5" C[green]="#a6e3a1" C[yellow]="#f9e2af"
    C[peach]="#fab387" C[orange]="#fab387"
    C[accent]="#b4befe"
    C[overlay2]="#9399b2"
    C[cat_accent]="lavender"
    C[kitty_theme]="catppuccin-mocha"
    C[gtk_theme]="Catppuccin-Mocha-GTK"
    C[gtk_scheme]="prefer-dark"
    C[kvantum_theme]="catppuccin-mocha-lavender"
    C[wallpaper_dir]="CatppuccinMocha"
    ;;
  rosepine)
    C[name]="Rosé Pine"
    C[base]="#191724" C[mantle]="#1f1d2e" C[crust]="#191724"
    C[surface0]="#26233a" C[surface1]="#403d52" C[surface2]="#524f67"
    C[overlay0]="#6e6a86" C[overlay1]="#908caa"
    C[text]="#e0def4" C[subtext1]="#e0def4" C[subtext0]="#908caa"
    C[red]="#eb6f92" C[maroon]="#eb6f92" C[rosewater]="#ebbcba" C[flamingo]="#ebbcba"
    C[pink]="#ebbcba" C[mauve]="#c4a7e7" C[lavender]="#c4a7e7"
    C[blue]="#31748f" C[sapphire]="#9ccfd8" C[sky]="#9ccfd8"
    C[teal]="#9ccfd8" C[green]="#9ccfd8" C[yellow]="#f6c177"
    C[peach]="#f6c177" C[orange]="#f6c177"
    C[accent]="#c4a7e7"
    C[overlay2]="#908caa"
    C[cat_accent]="lavender"
    C[kitty_theme]="rose-pine"
    C[gtk_theme]="Rosepine-GTK"
    C[gtk_scheme]="prefer-dark"
    C[kvantum_theme]="rose-pine-iris"
    C[wallpaper_dir]="RosePine"
    ;;
  gruvbox)
    C[name]="Gruvbox Dark"
    C[base]="#282828" C[mantle]="#1d2021" C[crust]="#1d2021"
    C[surface0]="#3c3836" C[surface1]="#504945" C[surface2]="#665c54"
    C[overlay0]="#928374" C[overlay1]="#a89984"
    C[text]="#ebdbb2" C[subtext1]="#d5c4a1" C[subtext0]="#bdae93"
    C[red]="#fb4934" C[maroon]="#cc241d" C[rosewater]="#d5c4a1" C[flamingo]="#d5c4a1"
    C[pink]="#d3869b" C[mauve]="#d3869b" C[lavender]="#83a598"
    C[blue]="#83a598" C[sapphire]="#83a598" C[sky]="#83a598"
    C[teal]="#8ec07c" C[green]="#b8bb26" C[yellow]="#fabd2f"
    C[peach]="#fe8019" C[orange]="#fe8019"
    C[accent]="#fabd2f"
    C[overlay2]="#a89984"
    C[cat_accent]="yellow"
    C[kitty_theme]="gruvbox-dark"
    C[gtk_theme]="Gruvbox-GTK"
    C[gtk_scheme]="prefer-dark"
    C[kvantum_theme]="gruvbox-kvantum"
    C[wallpaper_dir]="GruvboxDark"
    ;;
  everforest)
    C[name]="Everforest Dark"
    C[base]="#2d3b2d" C[mantle]="#283328" C[crust]="#232b23"
    C[surface0]="#374637" C[surface1]="#414f41" C[surface2]="#4a584a"
    C[overlay0]="#6a7b6a" C[overlay1]="#7a8b7a"
    C[text]="#d3c6aa" C[subtext1]="#c9b99a" C[subtext0]="#b9a98a"
    C[red]="#e67e80" C[maroon]="#e67e80" C[rosewater]="#c9b99a" C[flamingo]="#c9b99a"
    C[pink]="#df69ba" C[mauve]="#df69ba" C[lavender]="#7fbbb3"
    C[blue]="#7fbbb3" C[sapphire]="#7fbbb3" C[sky]="#7fbbb3"
    C[teal]="#83c092" C[green]="#a7c080" C[yellow]="#dbbc7f"
    C[peach]="#e69875" C[orange]="#e69875"
    C[accent]="#a7c080"
    C[overlay2]="#8a9b8a"
    C[cat_accent]="green"
    C[kitty_theme]="everforest"
    C[gtk_theme]="Everforest-GTK"
    C[gtk_scheme]="prefer-dark"
    C[kvantum_theme]="MateriaEverforestDark"
    C[wallpaper_dir]="Everforest"
    ;;
  carbonfox)
    C[name]="Carbonfox"
    C[base]="#161616" C[mantle]="#121212" C[crust]="#121212"
    C[surface0]="#222222" C[surface1]="#2a2a2a" C[surface2]="#525253"
    C[overlay0]="#6e7074" C[overlay1]="#9a9ca0"
    C[text]="#f2f4f8" C[subtext1]="#dfdfe0" C[subtext0]="#b2b4b8"
    C[red]="#ee5396" C[maroon]="#ee5396" C[rosewater]="#dfdfe0" C[flamingo]="#dfdfe0"
    C[pink]="#ff7eb6" C[mauve]="#be95ff" C[lavender]="#78a9ff"
    C[blue]="#78a9ff" C[sapphire]="#33b1ff" C[sky]="#33b1ff"
    C[teal]="#08bdba" C[green]="#25be6a" C[yellow]="#3ddbd9"
    C[peach]="#3ddbd9" C[orange]="#3ddbd9"
    C[accent]="#be95ff"
    C[overlay2]="#b2b4b8"
    C[cat_accent]="mauve"
    C[kitty_theme]="carbonfox"
    C[gtk_theme]="Gruvbox-GTK"
    C[gtk_scheme]="prefer-dark"
    C[kvantum_theme]="KvAdaptaDark"
    C[wallpaper_dir]="Carbonfox"
    ;;
  gruvbox-light)
    C[name]="Gruvbox Light"
    C[base]="#fbf1c7" C[mantle]="#f2e5bc" C[crust]="#f9f5d7"
    C[surface0]="#ebdbb2" C[surface1]="#d5c4a1" C[surface2]="#bdae93"
    C[overlay0]="#928374" C[overlay1]="#7c6f64"
    C[text]="#3c3836" C[subtext1]="#504945" C[subtext0]="#665c54"
    C[red]="#cc241d" C[maroon]="#9d0006" C[rosewater]="#504945" C[flamingo]="#504945"
    C[pink]="#b16286" C[mauve]="#8f3f71" C[lavender]="#458588"
    C[blue]="#458588" C[sapphire]="#076678" C[sky]="#076678"
    C[teal]="#689d6a" C[green]="#98971a" C[yellow]="#d79921"
    C[peach]="#d65d0e" C[orange]="#af3a03"
    C[accent]="#d79921"
    C[overlay2]="#7c6f64"
    C[cat_accent]="yellow"
    C[kitty_theme]="gruvbox-light"
    C[gtk_theme]="Gruvbox-GTK"
    C[gtk_scheme]="prefer-light"
    C[icon_theme]="Papirus-Light"
    C[kvantum_theme]="gruvbox-kvantum"
    C[wallpaper_dir]="GruvboxLight"
    ;;
  *)
    echo "Unknown theme: $THEME" >&2
    exit 1
    ;;
esac

# ── Kitty ───────────────────────────────────────────────────────────────────
switch_kitty() {
  local theme_conf="$HOME/.config/kitty/themes/${C[kitty_theme]}.conf"
  local current="$HOME/.config/kitty/themes/current.conf"
  if [ -f "$theme_conf" ]; then
    ln -sf "$theme_conf" "$current"
    kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true
  fi
}

# ── Yazi ────────────────────────────────────────────────────────────────────
gen_yazi_theme() {
  local tmpl="$HOME/.config/quickshell/templates/yazi-theme.toml.tmpl"
  [ -f "$tmpl" ] || return
  sed \
    -e "s/#1e1e2e/${C[base]}/g" \
    -e "s/#181825/${C[mantle]}/g" \
    -e "s/#11111b/${C[crust]}/g" \
    -e "s/#313244/${C[surface0]}/g" \
    -e "s/#45475a/${C[surface1]}/g" \
    -e "s/#585b70/${C[surface2]}/g" \
    -e "s/#6c7086/${C[overlay0]}/g" \
    -e "s/#7f849c/${C[overlay1]}/g" \
    -e "s/#9399b2/${C[overlay2]}/g" \
    -e "s/#cdd6f4/${C[text]}/g" \
    -e "s/#bac2de/${C[subtext1]}/g" \
    -e "s/#a6adc8/${C[subtext0]}/g" \
    -e "s/#f38ba8/${C[red]}/g" \
    -e "s/#eba0ac/${C[maroon]}/g" \
    -e "s/#f5e0dc/${C[rosewater]}/g" \
    -e "s/#f2cdcd/${C[flamingo]}/g" \
    -e "s/#f5c2e7/${C[pink]}/g" \
    -e "s/#cba6f7/${C[mauve]}/g" \
    -e "s/#b4befe/${C[lavender]}/g" \
    -e "s/#89b4fa/${C[blue]}/g" \
    -e "s/#74c7ec/${C[sapphire]}/g" \
    -e "s/#89dceb/${C[sky]}/g" \
    -e "s/#94e2d5/${C[teal]}/g" \
    -e "s/#a6e3a1/${C[green]}/g" \
    -e "s/#f9e2af/${C[yellow]}/g" \
    -e "s/#fab387/${C[peach]}/g" \
    "$tmpl" > "$HOME/.config/yazi/theme.toml"
}

# ── Neovim ──────────────────────────────────────────────────────────────────
nvim_reload() {
  local cs bg
  case "$THEME" in
    catppuccin)   cs="catppuccin"  bg="dark"  ;;
    rosepine)     cs="rose-pine"   bg="dark"  ;;
    gruvbox)      cs="gruvbox"     bg="dark"  ;;
    gruvbox-light) cs="gruvbox"   bg="light" ;;
    aura)         cs="aura-dark"   bg="dark"  ;;
    carbonfox)    cs="carbonfox"   bg="dark"  ;;
  esac
  local uid
  uid=$(id -u)
  for sock in $(find /run/user/"$uid" -maxdepth 3 -name "nvim.*" -type s 2>/dev/null); do
    nvim --server "$sock" \
      --remote-send ":set background=$bg | colorscheme $cs<CR>" \
      2>/dev/null || true
  done
}

# ── GTK ─────────────────────────────────────────────────────────────────────
switch_gtk() {
  local gtk_theme="${C[gtk_theme]}"
  local scheme="${C[gtk_scheme]}"
  local icons="${C[icon_theme]:-Papirus-Dark}"
  local prefer_dark
  prefer_dark=$([ "$scheme" = "prefer-dark" ] && echo 1 || echo 0)

  local settings_block
  settings_block="[Settings]
gtk-theme-name=$gtk_theme
gtk-application-prefer-dark-theme=$prefer_dark
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-icon-theme-name=$icons
gtk-cursor-theme-name=Phinger-Cursors
gtk-cursor-theme-size=24"

  mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
  echo "$settings_block" > "$HOME/.config/gtk-3.0/settings.ini"
  echo "$settings_block" > "$HOME/.config/gtk-4.0/settings.ini"

  # gsettings — live reload pour les apps en cours
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme      "$gtk_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme   "$scheme"    2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name      "JetBrainsMono Nerd Font 10" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme     "$icons"     2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme   "Phinger-Cursors" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size    24           2>/dev/null || true
  fi
}

# ── Btop ────────────────────────────────────────────────────────────────────
gen_btop_theme() {
  local theme_file="$HOME/.config/btop/themes/current.theme"
  mkdir -p "$(dirname "$theme_file")"
  cat > "$theme_file" << EOF
# ${C[name]} — auto-generated by switch-theme.sh
theme[main_bg]="${C[base]}"
theme[main_fg]="${C[text]}"
theme[title]="${C[text]}"
theme[hi_fg]="${C[accent]}"
theme[selected_bg]="${C[surface1]}"
theme[selected_fg]="${C[accent]}"
theme[inactive_fg]="${C[overlay1]}"
theme[graph_text]="${C[accent]}"
theme[meter_bg]="${C[surface1]}"
theme[proc_misc]="${C[rosewater]}"
theme[cpu_box]="${C[accent]}"
theme[mem_box]="${C[accent]}"
theme[net_box]="${C[accent]}"
theme[proc_box]="${C[accent]}"
theme[div_line]="${C[overlay0]}"
theme[temp_start]="${C[green]}"
theme[temp_mid]="${C[yellow]}"
theme[temp_end]="${C[red]}"
theme[cpu_start]="${C[teal]}"
theme[cpu_mid]="${C[sapphire]}"
theme[cpu_end]="${C[accent]}"
theme[free_start]="${C[mauve]}"
theme[free_mid]="${C[lavender]}"
theme[free_end]="${C[blue]}"
theme[cached_start]="${C[sapphire]}"
theme[cached_mid]="${C[blue]}"
theme[cached_end]="${C[accent]}"
theme[available_start]="${C[peach]}"
theme[available_mid]="${C[maroon]}"
theme[available_end]="${C[red]}"
theme[used_start]="${C[green]}"
theme[used_mid]="${C[teal]}"
theme[used_end]="${C[sky]}"
theme[download_start]="${C[peach]}"
theme[download_mid]="${C[maroon]}"
theme[download_end]="${C[red]}"
theme[upload_start]="${C[green]}"
theme[upload_mid]="${C[teal]}"
theme[upload_end]="${C[sky]}"
theme[process_start]="${C[accent]}"
theme[process_mid]="${C[sky]}"
theme[process_end]="${C[mauve]}"
EOF

  sed -i "s|^color_theme = .*|color_theme = \"$theme_file\"|" \
    "$HOME/.config/btop/btop.conf" 2>/dev/null || true
}

# ── Wallpaper ────────────────────────────────────────────────────────────────
switch_wallpaper() {
  local wp_dir="$HOME/Pictures/Wallpapers/${C[wallpaper_dir]}"
  [ -d "$wp_dir" ] || return
  local wp
  wp=$(find "$wp_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
  [ -n "$wp" ] && awww img "$wp" --transition-type wave --transition-duration 2 2>/dev/null || true
}

# ── Swaync ──────────────────────────────────────────────────────────────────
gen_swaync_style() {
  mkdir -p "$HOME/.config/swaync"
  cat > "$HOME/.config/swaync/style.css" << EOF
/* ${C[name]} — auto-generated by switch-theme.sh */
* {
  all: unset;
  font-size: 14px;
  font-family: "JetBrainsMono Nerd Font";
  transition: 200ms;
}

trough highlight { background: ${C[text]}; }

scale { margin: 0 7px; }

scale trough {
  margin: 0rem 1rem;
  min-height: 8px;
  min-width: 70px;
  border-radius: 12.6px;
}

trough slider {
  margin: -10px;
  border-radius: 12.6px;
  box-shadow: 0 0 2px rgba(0,0,0,0.8);
  transition: all 0.2s ease;
  background-color: ${C[blue]};
}

trough slider:hover {
  box-shadow: 0 0 2px rgba(0,0,0,0.8), 0 0 8px ${C[blue]};
}

trough { background-color: ${C[surface0]}; }

.notification-background {
  box-shadow: 0 0 8px 0 rgba(0,0,0,0.8), inset 0 0 0 1px ${C[surface1]};
  border-radius: 12.6px;
  margin: 18px;
  background: ${C[mantle]};
  color: ${C[text]};
  padding: 0;
}

.notification-background .notification {
  padding: 7px;
  border-radius: 12.6px;
}

.notification-background .notification.critical {
  box-shadow: inset 0 0 7px 0 ${C[red]};
}

.notification .notification-content { margin: 7px; }
.notification .notification-content overlay { margin: 4px; }

.notification-content .summary { color: ${C[text]}; }
.notification-content .time    { color: ${C[subtext0]}; }
.notification-content .body    { color: ${C[subtext1]}; }

.notification > *:last-child > * { min-height: 3.4em; }

.notification-background .close-button {
  margin: 7px;
  padding: 2px;
  border-radius: 6.3px;
  color: ${C[base]};
  background-color: ${C[red]};
}

.notification-background .close-button:hover  { background-color: ${C[maroon]}; }
.notification-background .close-button:active { background-color: ${C[pink]}; }

.notification .notification-action {
  border-radius: 7px;
  color: ${C[text]};
  box-shadow: inset 0 0 0 1px ${C[surface1]};
  margin: 4px;
  padding: 8px;
  background-color: ${C[surface0]};
}

.notification .notification-action:hover  { background-color: ${C[surface1]}; }
.notification .notification-action:active { background-color: ${C[surface2]}; }

.notification.critical progress { background-color: ${C[red]}; }
.notification.low progress,
.notification.normal progress   { background-color: ${C[blue]}; }

.notification progress,
.notification trough,
.notification progressbar {
  border-radius: 12.6px;
  padding: 3px 0;
}

.control-center {
  box-shadow: 0 0 8px 0 rgba(0,0,0,0.8), inset 0 0 0 1px ${C[surface0]};
  border-radius: 12.6px;
  background-color: ${C[base]};
  color: ${C[text]};
  padding: 14px;
}

.control-center .notification-background {
  border-radius: 7px;
  box-shadow: inset 0 0 0 1px ${C[surface1]};
  margin: 4px 10px;
}

.control-center .notification-background .notification {
  border-radius: 7px;
}

.control-center .notification-background .notification.low { opacity: 0.8; }

.control-center .widget-title > label {
  color: ${C[text]};
  font-size: 1.3em;
}

.control-center .widget-title button {
  border-radius: 7px;
  color: ${C[text]};
  background-color: ${C[surface0]};
  box-shadow: inset 0 0 0 1px ${C[surface1]};
  padding: 8px;
}

.control-center .widget-title button:hover  { background-color: ${C[surface1]}; }
.control-center .widget-title button:active { background-color: ${C[surface2]}; }

.control-center .notification-group { margin-top: 10px; }

.control-center .notification-group:focus .notification-background {
  background-color: ${C[surface0]};
}

scrollbar slider { margin: -3px; opacity: 0.8; }
scrollbar trough { margin: 2px 0; }

.widget-dnd {
  margin-top: 5px;
  border-radius: 8px;
  font-size: 1.1rem;
}

.widget-dnd > switch {
  font-size: initial;
  border-radius: 8px;
  background: ${C[surface0]};
  box-shadow: none;
}

.widget-dnd > switch:checked { background: ${C[blue]}; }

.widget-dnd > switch slider {
  background: ${C[surface1]};
  border-radius: 8px;
}

.widget-mpris-player {
  background: ${C[surface0]};
  border-radius: 12.6px;
  color: ${C[text]};
}

.mpris-overlay {
  background-color: ${C[surface0]};
  opacity: 0.9;
  padding: 15px 10px;
}

.widget-mpris-album-art {
  -gtk-icon-size: 100px;
  border-radius: 12.6px;
  margin: 0 10px;
}

.widget-mpris-title    { font-size: 1.2rem; color: ${C[text]}; }
.widget-mpris-subtitle { font-size: 1rem;   color: ${C[subtext1]}; }

.widget-mpris button {
  border-radius: 12.6px;
  color: ${C[text]};
  margin: 0 5px;
  padding: 2px;
}

.widget-mpris button image    { -gtk-icon-size: 1.8rem; }
.widget-mpris button:hover    { background-color: ${C[surface0]}; }
.widget-mpris button:active   { background-color: ${C[surface1]}; }
.widget-mpris button:disabled { opacity: 0.5; }

.widget-volume { padding: 1rem 0; }

.widget-volume label {
  color: ${C[sapphire]};
  padding: 0 1rem;
}

.widget-volume trough highlight   { background: ${C[sapphire]}; }
.widget-backlight trough highlight { background: ${C[yellow]}; }

.widget-backlight label {
  font-size: 1.5rem;
  color: ${C[yellow]};
}

.widget-backlight .KB { padding-bottom: 1rem; }

.image { padding-right: 0.5rem; }
EOF

  swaync-client -rs 2>/dev/null || true
}

# ── Qt (Kvantum + qt5ct/qt6ct) ──────────────────────────────────────────────
switch_qt() {
  local kvantum_theme="${C[kvantum_theme]}"
  local icons="${C[icon_theme]:-Papirus-Dark}"

  # Kvantum theme
  mkdir -p "$HOME/.config/Kvantum"
  cat > "$HOME/.config/Kvantum/kvantum.kvconfig" << EOF
[General]
theme=$kvantum_theme
EOF

  # qt5ct + qt6ct
  local font_str="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
  for ct_dir in "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"; do
    mkdir -p "$ct_dir"
    cat > "$ct_dir/$(basename "$ct_dir").conf" << EOF
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=$icons
standard_dialogs=default
style=kvantum

[Fonts]
fixed="$font_str"
general="$font_str"
EOF
  done
}

# ── Hyprland borders ────────────────────────────────────────────────────────
live_reload() {
  if command -v hyprctl &>/dev/null; then
    local active_hex="${C[accent]#\#}"
    local inactive_hex="${C[surface0]#\#}"
    hyprctl keyword general:col.active_border "rgba(${active_hex}ff)" 2>/dev/null || true
    hyprctl keyword general:col.inactive_border "rgba(${inactive_hex}ff)" 2>/dev/null || true
  fi
}

# ── Fastfetch ───────────────────────────────────────────────────────────────
gen_fastfetch_config() {
  local cfg="$HOME/.config/fastfetch/config.jsonc"
  [ -f "$cfg" ] || return
  sed -i \
    -e "s/\"keyColor\": \"#[0-9A-Fa-f]\{6\}\"/\"keyColor\": \"${C[accent]}\"/g" \
    -e "s/\"1\": \"#[0-9A-Fa-f]\{6\}\"/\"1\": \"${C[accent]}\"/g" \
    -e "s/\"2\": \"#[0-9A-Fa-f]\{6\}\"/\"2\": \"${C[accent]}\"/g" \
    "$cfg"
}

# ── Cider ───────────────────────────────────────────────────────────────────
switch_cider() {
  local theme_dir="$HOME/.config/sh.cider.genten/themes/quickshell"
  mkdir -p "$theme_dir"

  cat > "$theme_dir/theme.yml" << EOF
name: Quickshell Theme
author: quickshell
stylesheets:
  - name: ${C[name]}
    file: quickshell.scss
    description: Auto-generated by switch-theme.sh
version: "1.0"
EOF

  cat > "$theme_dir/quickshell.scss" << EOF
body.body--dark {
  --accent:   ${C[accent]};
  --text:     ${C[text]};
  --subtext1: ${C[subtext1]};
  --subtext0: ${C[subtext0]};
  --overlay1: ${C[overlay1]};
  --overlay0: ${C[overlay0]};
  --surface0: ${C[surface0]};
  --base:     ${C[base]};
  --mantle:   ${C[mantle]};
  --crust:    ${C[crust]};

  --selection-bg: ${C[accent]}4d;
  --red:   ${C[red]};
  --green: ${C[green]};
  --blue:  ${C[blue]};

  background: var(--crust);
  color: var(--text);
  --textDefault: var(--text);
  --systemPrimary: var(--text);
  --systemSecondary: var(--text);
  --systemTertiary: var(--surface0);
  --systemQuinary: var(--selection-bg);
  --systemQuaternary: var(--selection-bg);
  --keyColor: var(--accent);
  --musicKeyColor: var(--accent);
  --tracklistAltRowColor: transparent;
  --vibrantDivider: var(--surface0);
  --q-primary: var(--accent);
  --q-info: var(--blue);
}
EOF
}

# ── Vesktop ─────────────────────────────────────────────────────────────────
switch_vesktop() {
  local theme_file="$HOME/.config/vesktop/themes/quickshell-theme.css"
  mkdir -p "$(dirname "$theme_file")"
  cat > "$theme_file" << EOF
/**
 * @name quickshell-theme
 * @description ${C[name]} — auto-generated by switch-theme.sh
 * @author quickshell
 * @version 1.0.0
 */

:root,
.theme-dark,
.theme-light {
  /* === Backgrounds (new Discord variable names) === */
  --app-frame-background:           ${C[crust]};
  --background-base-lowest:         ${C[crust]};
  --background-base-lower:          ${C[mantle]};
  --background-base-low:            ${C[mantle]};
  --background-surface-high:        ${C[base]};
  --background-surface-higher:      ${C[surface0]};
  --background-accent:              ${C[surface1]};
  --chat-background:                ${C[base]};
  --home-background:                ${C[base]};
  --modal-background:               ${C[base]};
  --channeltextarea-background:      ${C[mantle]};
  --input-background-default:        ${C[crust]};
  --input-text-default:              ${C[text]};
  --input-placeholder-text-default:  ${C[subtext1]};
  --input-border-default:            ${C[overlay0]};
  --custom-status-bubble-background: ${C[crust]};
  --border-normal:                   ${C[surface0]};
  --border-faint:                    ${C[surface0]}60;
  --channel-icon:                    ${C[overlay1]};
  --interactive-background-selected: ${C[surface0]}60;
  --interactive-background-active:   ${C[surface0]}40;

  /* === Text (new names) === */
  --text-default:                  ${C[text]};
  --text-muted:                    ${C[subtext0]};
  --text-subtle:                   ${C[subtext1]};
  --text-link:                     ${C[blue]};
  --text-positive:                 ${C[green]};
  --text-warning:                  ${C[yellow]};
  --text-danger:                   ${C[red]};
  --text-brand:                    ${C[accent]};

  /* === Interactive === */
  --interactive-text-default:      ${C[text]};
  --interactive-background-hover:  ${C[surface0]}60;
  --channels-default:              ${C[overlay1]};
  --icon-muted:                    ${C[overlay1]};

  /* === Brand / Accent === */
  --brand-500:                     ${C[accent]};
  --brand-560:                     ${C[accent]};
  --brand-600:                     ${C[accent]};
  --brand-700:                     ${C[mauve]};
  --control-primary-background-default: ${C[accent]};
  --control-secondary-background-default: ${C[surface1]};
  --logo-primary:                  ${C[accent]};

  /* === Scrollbar === */
  --scrollbar-thin-thumb:          ${C[surface1]};
  --scrollbar-auto-thumb:          ${C[surface1]};
  --scrollbar-auto-track:          ${C[mantle]};

  /* === Brand spectrum (covers selected home button) === */
  --brand-100: ${C[surface0]};
  --brand-200: ${C[surface0]};
  --brand-300: ${C[surface1]};
  --brand-360: ${C[surface2]};
  --brand-400: ${C[overlay0]};
  --brand-430: ${C[overlay0]};
  --brand-460: ${C[overlay1]};
  --brand-500: ${C[accent]};
  --brand-530: ${C[accent]};
  --brand-560: ${C[accent]};
  --brand-600: ${C[accent]};
  --brand-630: ${C[mauve]};
  --brand-660: ${C[mauve]};
  --brand-700: ${C[mauve]};
  --brand-800: ${C[mauve]};
  --brand-900: ${C[base]};

  /* === Missing backgrounds === */
  --background-surface-highest:    ${C[surface1]} !important;
  --bg-surface-raised:             ${C[mantle]};
  --background-gradient-highest:   ${C[mantle]};
  --chat-background-default:       ${C[base]};
  --chat-border:                   ${C[crust]};
  --__header-bar-background:       ${C[mantle]} !important;
  --custom-channel-members-bg:     ${C[mantle]};
  --card-background-default:       ${C[surface0]} !important;
  --modal-footer-background:       ${C[base]};
  --user-profile-overlay-background: ${C[mantle]};
  --background-secondary-alt:      ${C[mantle]} !important;
  --background-mod-subtle:         ${C[surface0]}40 !important;
  --background-mod-strong:         ${C[surface1]}72 !important;

  /* === Legacy variables (older Discord/Vencord) === */
  --background-primary:            ${C[base]};
  --background-secondary:          ${C[mantle]};
  --background-tertiary:           ${C[crust]};
  --background-floating:           ${C[mantle]};
  --background-modifier-hover:     ${C[surface0]}60;
  --background-modifier-active:    ${C[surface1]}80;
  --background-modifier-selected:  ${C[surface1]}60;
  --text-normal:                   ${C[text]};
  --header-primary:                ${C[text]};
  --header-secondary:              ${C[subtext1]};
  --interactive-normal:            ${C[subtext1]};
  --interactive-hover:             ${C[text]};
  --interactive-active:            ${C[accent]};
  --interactive-muted:             ${C[overlay1]};
  --focus-primary:                 ${C[accent]};
  --brand-experiment:              ${C[accent]};
  --brand-experiment-560:          ${C[accent]};
}

/* Fix Discord home button selected state (SVG circle) */
.visual-refresh.theme-dark svg[class^=selectedIcon_]>circle[fill=white],
.visual-refresh .theme-dark svg[class^=selectedIcon_]>circle[fill=white],
svg[class^=selectedIcon_]>circle[fill=white] {
  fill: ${C[crust]};
}
EOF
}

# ── Steam (Millennium Quick CSS) ─────────────────────────────────────────────
switch_steam() {
  local quickcss="$HOME/.config/millennium/quickcss.css"
  [ -f "$quickcss" ] || return

  cat > "$quickcss" << EOF
/* Quickshell theme — auto-generated by switch-theme.sh */
:root {
    --color-light:   ${C[surface1]} !important;
    --color-dark:    ${C[mantle]}   !important;
    --color-darker:  ${C[base]}     !important;
    --color-darkest: ${C[crust]}    !important;
    --scrollbar:     ${C[surface1]} !important;
    --black:         ${C[crust]}    !important;
    --black-ish:     ${C[crust]}    !important;
    --realblack:     ${C[crust]}    !important;
    --blacker-ish:   ${C[crust]}    !important;
    --blacker:       ${C[crust]}    !important;
    --lightblack:    ${C[crust]}    !important;
    --darkergrey:    ${C[crust]}    !important;
    --bedarkgrey:    ${C[crust]}    !important;
    --thegrey:       ${C[mantle]}   !important;
    --begrey:        ${C[surface0]} !important;
    --littlegrey:    ${C[surface0]} !important;
    --darkgrey:      ${C[base]}     !important;
    --grey:          ${C[surface0]} !important;
    --lightgrey:     ${C[surface1]} !important;
    --lightergrey:   ${C[surface0]} !important;
    --grey-ish:      ${C[surface2]} !important;
    --darkerwhite:   ${C[subtext0]} !important;
    --darkwhite:     ${C[subtext1]} !important;
    --white:         ${C[text]}     !important;
    --ingame:        ${C[green]}    !important;
    --online:        ${C[teal]}     !important;
    --offline:       ${C[overlay0]} !important;
}
EOF
}

# ── OBS Studio ──────────────────────────────────────────────────────────────
switch_obs() {
  local theme_dir="$HOME/.config/obs-studio/themes"
  local theme_file="$theme_dir/Quickshell.obt"
  local user_ini="$HOME/.config/obs-studio/user.ini"
  mkdir -p "$theme_dir"

  local is_dark
  is_dark=$([ "$THEME" = "gruvbox-light" ] && echo "false" || echo "true")

  cat > "$theme_file" << EOF
@OBSThemeMeta {
    name: 'Quickshell';
    id: 'io.github.quickshell';
    extends: 'com.obsproject.Yami';
    author: 'quickshell';
    dark: '$is_dark';
}

@OBSThemeVars {
    --bg_window: ${C[mantle]};
    --bg_base: ${C[base]};
    --bg_preview: ${C[crust]};

    --primary: ${C[accent]};
    --primary_light: ${C[blue]};
    --primary_lighter: ${C[sky]};
    --primary_dark: ${C[accent]};
    --primary_darker: ${C[mauve]};

    --warning: ${C[yellow]};
    --danger: ${C[red]};

    --text: ${C[text]};
    --text_light: ${C[subtext1]};
    --text_muted: ${C[subtext0]};
    --text_disabled: ${C[overlay0]};
    --text_inactive: ${C[text]};

    --input_bg: ${C[surface0]};
    --input_bg_hover: ${C[surface1]};
    --input_bg_focus: ${C[surface0]};
    --input_border: ${C[overlay0]};
    --input_border_hover: ${C[overlay1]};
    --input_border_focus: ${C[accent]};

    --border_color: ${C[surface1]};

    --button_bg: ${C[surface0]};
    --button_bg_hover: ${C[surface1]};
    --button_bg_down: ${C[surface2]};
    --button_bg_disabled: ${C[mantle]};
    --button_border: ${C[surface0]};
    --button_border_hover: ${C[overlay0]};
    --button_border_focus: ${C[overlay0]};

    --scrollbar_handle: ${C[surface1]};
    --scrollbar_bg: ${C[base]};
    --scrollbar_hover: ${C[surface2]};
    --scrollbar_down: ${C[overlay0]};
    --scrollbar_border: ${C[surface1]};

    --tab_bg: ${C[mantle]};
    --tab_bg_hover: ${C[surface0]};
    --tab_bg_down: ${C[accent]};
    --tab_bg_disabled: ${C[mantle]};
    --tab_border: ${C[surface1]};
    --tab_border_hover: ${C[overlay0]};
    --tab_border_focus: ${C[accent]};
    --tab_border_selected: ${C[accent]};
}
EOF

  if [ -f "$user_ini" ]; then
    if grep -q "^Theme=" "$user_ini"; then
      sed -i "s|^Theme=.*|Theme=io.github.quickshell|" "$user_ini"
    else
      sed -i '/^\[Appearance\]/a Theme=io.github.quickshell' "$user_ini"
    fi
  fi
}

# ── Zen Browser ─────────────────────────────────────────────────────────────
switch_zen() {
  local profile_dir="$HOME/.config/zen/997wg1bq.Default (release)"
  local chrome_dir="$profile_dir/chrome"
  local user_js="$profile_dir/user.js"
  local user_chrome="$chrome_dir/userChrome.css"
  local user_content="$chrome_dir/userContent.css"

  mkdir -p "$chrome_dir"

  local dark_mode
  case "${C[gtk_scheme]}" in
    prefer-light) dark_mode=0 ;;
    *)            dark_mode=1 ;;
  esac

  # Write user.js with required prefs
  {
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
    echo "user_pref(\"ui.systemUsesDarkTheme\", ${dark_mode});"
  } > "$user_js"

  cat > "$user_chrome" << EOF
/* Quickshell theme - auto-generated, do not edit */
:root {
  --zen-colors-primary:           ${C[surface0]} !important;
  --zen-primary-color:            ${C[accent]} !important;
  --zen-colors-secondary:         ${C[surface0]} !important;
  --zen-colors-tertiary:          ${C[mantle]} !important;
  --zen-colors-border:            ${C[accent]} !important;
  --zen-themed-toolbar-bg:        ${C[mantle]} !important;
  --zen-main-browser-background:  ${C[mantle]} !important;
  --toolbox-bgcolor-inactive:     ${C[mantle]} !important;
  --toolbarbutton-icon-fill:      ${C[accent]} !important;
  --lwt-text-color:               ${C[text]} !important;
  --toolbar-field-color:          ${C[text]} !important;
  --tab-selected-textcolor:       ${C[text]} !important;
  --toolbar-field-focus-color:    ${C[text]} !important;
  --toolbar-color:                ${C[text]} !important;
  --newtab-text-primary-color:    ${C[text]} !important;
  --arrowpanel-color:             ${C[text]} !important;
  --arrowpanel-background:        ${C[base]} !important;
  --sidebar-text-color:           ${C[text]} !important;
  --lwt-sidebar-text-color:       ${C[text]} !important;
  --lwt-sidebar-background-color: ${C[crust]} !important;
  --toolbar-bgcolor:              ${C[surface0]} !important;
  --newtab-background-color:      ${C[base]} !important;
}

#permissions-granted-icon {
  color: ${C[mantle]} !important;
}

.sidebar-placesTree {
  background-color: ${C[base]} !important;
}

#zen-workspaces-button {
  background-color: ${C[base]} !important;
}

#TabsToolbar {
  background-color: ${C[mantle]} !important;
  color: ${C[text]} !important;
}

#TabsToolbar * {
  color: ${C[text]} !important;
}

hbox#titlebar {
  background-color: ${C[mantle]} !important;
  color: ${C[text]} !important;
}

#zen-appcontent-navbar-container {
  background-color: ${C[mantle]} !important;
}

.urlbar-background {
  background-color: ${C[base]} !important;
}

.content-shortcuts {
  background-color: ${C[base]} !important;
  border-color: ${C[accent]} !important;
}

.urlbarView-url {
  color: ${C[accent]} !important;
}

#zenEditBookmarkPanelFaviconContainer {
  background: ${C[crust]} !important;
}
EOF

  cat > "$user_content" << EOF
/* Quickshell theme - auto-generated, do not edit */
@-moz-document url-prefix("about:") {
  :root {
    --in-content-page-color:      ${C[text]} !important;
    --color-accent-primary:       ${C[accent]} !important;
    --color-accent-primary-hover: ${C[blue]} !important;
    background-color:             ${C[base]} !important;
    --in-content-page-background: ${C[base]} !important;
  }
}

@-moz-document url("about:newtab"), url("about:home") {
  :root {
    --newtab-background-color:           ${C[base]} !important;
    --newtab-background-color-secondary: ${C[surface0]} !important;
    --newtab-element-hover-color:        ${C[surface0]} !important;
    --newtab-text-primary-color:         ${C[text]} !important;
    --newtab-wordmark-color:             ${C[text]} !important;
    --newtab-primary-action-background:  ${C[accent]} !important;
  }
}

@-moz-document url-prefix("about:preferences") {
  :root {
    --zen-colors-tertiary:       ${C[mantle]} !important;
    --in-content-text-color:     ${C[text]} !important;
    --link-color:                ${C[accent]} !important;
    --link-color-hover:          ${C[blue]} !important;
    --zen-colors-primary:        ${C[surface0]} !important;
    --in-content-box-background: ${C[surface0]} !important;
    --zen-primary-color:         ${C[accent]} !important;
  }

  .main-content {
    background-color: ${C[crust]} !important;
  }
}
EOF
}

# ── Userstyles (Stylus via userContent.css) ─────────────────────────────────
gen_userstyles() {
  local cache_dir="$HOME/.config/quickshell/scripts/userstyles-cache"
  local compile_js="$HOME/.config/quickshell/scripts/compile-userstyle.js"
  local user_content="/home/honey/.config/zen/997wg1bq.Default (release)/chrome/userContent.css"

  local palette
  palette=$(printf '{
    "rosewater":"%s","flamingo":"%s","pink":"%s","mauve":"%s",
    "red":"%s","maroon":"%s","peach":"%s","yellow":"%s",
    "green":"%s","teal":"%s","sky":"%s","sapphire":"%s",
    "blue":"%s","lavender":"%s","text":"%s","subtext1":"%s",
    "subtext0":"%s","overlay2":"%s","overlay1":"%s","overlay0":"%s",
    "surface2":"%s","surface1":"%s","surface0":"%s",
    "base":"%s","mantle":"%s","crust":"%s","accentColor":"%s"
  }' \
    "${C[rosewater]}" "${C[flamingo]}" "${C[pink]}"     "${C[mauve]}"   \
    "${C[red]}"       "${C[maroon]}"   "${C[peach]}"    "${C[yellow]}"  \
    "${C[green]}"     "${C[teal]}"     "${C[sky]}"      "${C[sapphire]}"\
    "${C[blue]}"      "${C[lavender]}" "${C[text]}"     "${C[subtext1]}"\
    "${C[subtext0]}"  "${C[overlay2]}" "${C[overlay1]}" "${C[overlay0]}"\
    "${C[surface2]}"  "${C[surface1]}" "${C[surface0]}"                 \
    "${C[base]}"      "${C[mantle]}"   "${C[crust]}"    "${C[cat_accent]}")

  # Start with the about: rules already in userContent.css (everything before userstyles block)
  # then append compiled site CSS
  local tmp
  tmp=$(mktemp)

  # Keep the existing about: page rules
  sed '/^\/\* --- userstyles ---/,$d' "$user_content" > "$tmp" 2>/dev/null || cp "$user_content" "$tmp"

  echo "/* --- userstyles --- */" >> "$tmp"

  local sites=(youtube twitch twitter instagram reddit github codeberg proton claude anilist duckduckgo wikipedia)
  for site in "${sites[@]}"; do
    local less_file="$cache_dir/$site.user.less"
    [ -f "$less_file" ] || continue
    echo "/* == $site == */" >> "$tmp"
    node "$compile_js" "$less_file" "$palette" >> "$tmp" 2>/dev/null || true
  done

  mv "$tmp" "$user_content"
}

# ── Main ────────────────────────────────────────────────────────────────────
switch_kitty
gen_btop_theme
gen_yazi_theme
gen_swaync_style
nvim_reload
switch_gtk
switch_qt
live_reload
switch_wallpaper
gen_fastfetch_config
switch_cider
switch_vesktop
switch_steam
switch_obs
switch_zen
gen_userstyles

echo "Switched theme to: ${C[name]}"
