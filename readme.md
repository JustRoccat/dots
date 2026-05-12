# Installation

> This guide assumes you already have a working **Hyprland** setup. It will walk you through installing all dependencies and copying the config files from the archive.

---

## Dependencies

Install all required packages (Arch Linux / yay):

```bash
yay -S quickshell-git \
        swww \
        cava \
        python-pywal \
        cliphist \
        wl-clipboard \
        socat \
        jq \
        playerctl \
        hyprshot \
        brightnessctl \
        hyprpolkitagent \
        ttf-nunito \
        nerd-fonts-caskaydia-cove \
        ttf-jetbrains-mono \
        papirus-icon-theme
```

Optional (used in the Hyprland config):

```bash
yay -S zen-browser dolphin kitty
```

---

## Monitor Setup

Before copying anything, **check your monitor names**:

```bash
hyprctl monitors
```

Then open `hyprland.conf` and replace the monitor lines with your own:

```ini
# Replace HDMI-A-1 and DP-3 with your actual monitor names
monitor = HDMI-A-1, 1920x1080@100, 1920x0, 1
monitor = DP-3,    1920x1080@60,   0x0,    1
```

Do the same in `quickshell/Bar.qml` — find this line and change the monitor name:

```qml
if (list[i].name === "HDMI-A-1") return list[i]
```

---

## Copying Config Files

Extract the archive first:

```bash
tar -xzf Purple_Dots.tar.gz
cd "Purple Dots"
```

### Quickshell

```bash
mkdir -p ~/.config/quickshell
cp quickshell/*.qml ~/.config/quickshell/
```

### Scripts (CAVA)

```bash
cp quickshell/start-cava.sh quickshell/manage_cava_process.sh ~/.config/quickshell/
chmod +x ~/.config/quickshell/*.sh
```

### Hyprland

```bash
# Back up your current config first!
cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.bak

cp hyprland.conf ~/.config/hypr/
```

### Wallpapers

```bash
mkdir -p ~/Pictures/wallpapers
cp Wallpapers/* ~/Pictures/wallpapers/
```

---

## Pywal Setup

Pywal generates a color palette from your wallpaper and feeds it to Quickshell, which dynamically updates the UI accent colors.

Set your first wallpaper and generate the palette:

```bash
# Start swww and set a wallpaper
swww-daemon &
swww img ~/Pictures/wallpapers/edgerunners.png

# Generate colors with pywal
wal -i ~/Pictures/wallpapers/edgerunners.png --backend colorz -n
```

After the initial setup, changing wallpapers through the **WallpaperPicker** in the bar will automatically regenerate pywal colors for you.

---

## First Launch

Reload Hyprland:

```bash
hyprctl reload
```

Or if you're starting from a TTY:

```bash
Hyprland
```

---

## Keybinds

| Shortcut | Action |
|----------|--------|
| `SUPER + Space` or `Super_L` | App launcher |
| `SUPER + Z` | Terminal (kitty) |
| `SUPER + W` | Browser (zen-browser) |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + Space` | Toggle floating |
| `SUPER + H/J/K/L` | Focus (vim-style) |
| `SUPER + ALT + arrows` | Resize window |
| `SUPER + SHIFT + S` | Region screenshot → clipboard |
| `Print` | Full output screenshot |
| Click on the clock | Open control panel |
| Click on the playing track | Open music player |

---

## Troubleshooting

**Quickshell won't start**
Check the logs:
```bash
quickshell 2>&1 | head -50
```

**CAVA visualizer is empty / not working**
Run the script manually and check for errors:
```bash
bash ~/.config/quickshell/manage_cava_process.sh
```
Make sure you have a working PulseAudio or PipeWire server running.

**Colors don't change with the wallpaper**
Check that pywal is installed and that `~/.cache/wal/colors.json` exists after running `wal -i ...`.

**Icons not showing in the launcher**
Make sure `papirus-icon-theme` is installed and set as the default:
```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
```
