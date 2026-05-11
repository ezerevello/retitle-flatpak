# retitle-flatpak

A bash script to change the window title of Flatpak apps by patching their interpreted source files (Python/JS).

## Why this ahh tool exists?

Born from trying to rename the [ZapZap](https://flathub.org/apps/com.rtosta.zapzap) WhatsApp wrapper window to match its custom icon, because the original title is "ZapZap" and I don't like it. And then discovering that KWin's "Special Window Settings" only identifies windows, not renames them.

On **Wayland**, no external process can change the window title of another app — the protocol simply doesn't allow it. Tools like `wmctrl`, `xdotool`, and KWin special window rules can't do it either (those are window identifiers, not title setters).

The only real way in is **inside the app's own source**. Many Flatpak apps are written in Python or JS, meaning their source ships readable and patchable. This script finds the `setWindowTitle` call and replaces the string directly.

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
retitle-flatpak com.rtosta.zapzap "Telegram"
retitle-flatpak org.telegram.desktop "Spotify"
retitle-flatpak com.spotify.Client "WhatsApp"
```

To find the App ID of any installed Flatpak:

```bash
flatpak list --app
```

---

## How it works

1. Resolves the installation path of the Flatpak via `flatpak info --show-location`
2. Scans all `.py` and `.js` files inside the app bundle for `setWindowTitle`, `set_title`, or `window.title` calls
3. Shows every match and asks for confirmation before touching anything
4. Patches the file(s) with `sudo sed -i`, replacing the old title string with the new one
5. The change takes effect on next app launch

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
