# retitle-flatpak

A bash script to change the window title of Flatpak apps by patching their interpreted source files (Python/JS).

## Why this ahh tool exists?

Born from trying to rename the [ZapZap](https://flathub.org/apps/com.rtosta.zapzap) WhatsApp wrapper window to match my customization, because the original title is "ZapZap" and I don't like it. And then discovering that KWin's "Special Window Settings" only identifies windows, not renames them.

**Clarification: I did a basic script for me, to change ZapZap window title, but then i thought that make a complete script for people searching the same exact thing as me would be cool, so this is only a "premium" version o a basic script to make this easy to use for me and you**

So i did this in my free time only for fun and for save myself time in the future if I want to change the same thing

----

## Why this overcomplicated method?
On **Wayland**, no external process can change the window title of another app — the protocol simply doesn't allow it. Tools like `wmctrl`, `xdotool`, and KWin special window rules can't do it either (those are window identifiers, not title setters)

The only real way in is **inside the app's own source**. Many Flatpak apps are written in Python or JS, meaning their source ships readable and patchable. This script finds the window title call and replaces the string directly.

**Only tested on:** Fedora 44 · KDE Plasma · Wayland

---

## Apps List
Here's a list that includes applications that run using interpreters or engines:

### 🐍 Python Based
*   ZapZap
*   Parabolic (Tube Converter)
*   Tauon Music Box
*   BleachBit
*   Gramps
*   Deluge (Gtk UI)
*   Gajim
*   OpenShot Video Editor
*   Curlew

### 🌐 Electron / JavaScript Based
*   Visual Studio Code
*   Discord
*   Obsidian
*   Logseq
*   Bitwarden
*   Etcher
*   WebTorrent Desktop
*   Cider
*   Standard Notes
*   Mailspring
*   Signal Desktop

### ☕ Java / JVM Based
*   Minecraft (Java Edition)
*   IntelliJ IDEA
*   PyCharm
*   DBeaver
*   FreeMind
*   RSSOwl


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

The only app verified 100% is **ZapZap** (`com.rtosta.zapzap`), because that's the one that started all this.

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

## License

MIT
