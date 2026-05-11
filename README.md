# retitle-flatpak

A bash script to change the window title of Flatpak apps by patching their interpreted source files (Python/JS).

## Why this ahh tool exists?

Born from trying to rename the [ZapZap](https://flathub.org/apps/com.rtosta.zapzap) WhatsApp wrapper window to match its custom icon, because the original title is "ZapZap" and I don't like it. And then discovering that KWin's "Special Window Settings" only identifies windows, not renames them.

On **Wayland**, no external process can change the window title of another app — the protocol simply doesn't allow it. Tools like `wmctrl`, `xdotool`, and KWin special window rules can't do it either (those are window identifiers, not title setters).

The only real way in is **inside the app's own source**. Many Flatpak apps are written in Python or JS, meaning their source ships readable and patchable. This script finds the window title call and replaces the string directly.

**Only tested on:** Fedora 44 · KDE Plasma · Wayland

---

## Installation

```bash
git clone https://github.com/ezerevello/retitle-flatpak
cd retitle-flatpak
chmod +x install.sh
./install.sh
```

`install.sh` copies the script to `~/.local/bin` and handles `$PATH` automatically — it detects your shell (zsh, bash, fish, ksh) and adds `~/.local/bin` to your config file only if it isn't already there.

**Supported shells:** zsh · bash · fish · ksh

---

## Usage

```bash
retitle-flatpak <APP_ID> "<new title>"
```

### Examples

```bash
retitle-flatpak com.rtosta.zapzap "WhatsApp"
retitle-flatpak org.telegram.desktop "Telegram"
retitle-flatpak com.spotify.Client "Spotify"
```

To find the App ID of any installed Flatpak:

```bash
flatpak list --app
```

---

## How it works

1. Resolves the installation path of the Flatpak via `flatpak info --show-location`
2. Scans all `.py` and `.js` files inside the app bundle for any supported window title pattern
3. Classifies each file by framework and shows every match before touching anything
4. Asks for confirmation, then patches with `sudo sed -i`
5. The change takes effect on next app launch

### Supported frameworks

The script detects and patches all of these automatically:

| Pattern | Framework |
|---|---|
| `setWindowTitle(_("Title"))` | PyQt / PySide + gettext |
| `setWindowTitle("Title")` | PyQt / PySide plain |
| `.set_title(_("Title"))` | GTK Python + gettext |
| `.set_title("Title")` | GTK Python plain |
| `.setTitle("Title")` | Electron / JS |

---

## Compatibility

Honestly, I can't guarantee this works for every Flatpak out there — it depends entirely on how each app sets its window title internally, and there are dozens of ways to do it. What I can say is that the script covers the five most common patterns across PyQt, GTK, and Electron apps.

The only app verified 100% is **ZapZap** (`com.rtosta.zapzap`), because that's the one that started all this. If you try it on another app and it works, open a PR or an issue and I'll add it to the list.

### Confirmed working

| App | App ID | Framework |
|---|---|---|
| ZapZap | `com.rtosta.zapzap` | PyQt + gettext |

---

## Limitations

| Limitation | Details |
|---|---|
| **Interpreted apps only** | Works for Python and JS. Compiled apps (C++, Rust, Go) ship no readable source — not patchable this way. |
| **Patches lost on update** | Flatpak updates restore the original files. Re-run the script after every app update. |
| **Translated titles** | Apps using `_("Title")` (gettext) may revert the title at runtime based on locale. |
| **Wayland only concern** | On X11 you could use `xdotool` instead. This tool targets Wayland where that's not an option. |

---

## Reverting a change

Re-run with the original title:

```bash
retitle-flatpak com.rtosta.zapzap "ZapZap"
```

Or reinstall the app to restore all original files:

```bash
flatpak repair com.rtosta.zapzap
# or
flatpak uninstall com.rtosta.zapzap && flatpak install com.rtosta.zapzap
```

---

## Repo structure

```
retitle-flatpak/
├── retitle-flatpak   ← main script
├── install.sh        ← installer (copies script + handles PATH)
└── README.md
```

---

## License

MIT
