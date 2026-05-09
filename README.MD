# macOS Dotfiles & Environment Setup

A completely automated and interactive bootstrap script to turn a fresh macOS installation into a fully configured developer environment or an everyday machine in minutes.

This repository has an `install.sh` script (very much optional, please go through the script before you run it for your safety) that automatically clones all the dotfiles, installs Homebrew, safely symlinks configs, and dynamically loads Zsh plugins only if their dependencies exist. Repository is available on both Github and Codeberg.

## 🛠 Installation

To initialise your new Mac, open `Terminal.app` and run ONE of the following commands:

**From GitHub:**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/blud0t/dotfiles/main/install.sh)"
```

**From Codeberg:**

```bash
bash -c "$(curl -fsSL https://codeberg.org/blud0t/dotfiles/raw/branch/main/install.sh)"
```

The script will pause to let you install the Apple Command Line Tools if needed, and then launch an interactive menu to ask how you want to build your machine.

### The 3 Installation Paths:

1. **Minimal:** Installs the core CLI tools (Zsh customisations, `powerlevel10k`, `eza`, `bat`, `fzf`), `WezTerm`, a custom font, and everyday GUI utilities (browsers, media players, screenshot tools). Perfect for a daily-driver laptop.
2. **Developer:** Installs everything in Minimal, plus dev tools: VS Code, Zed, C++ build tools (CMake, Ninja), version managers (pyenv, nvm), database CLIs (MongoDB, SQLite), and UTM for VMs.
3. **Custom:** A modular, interactive `[Y/n]` flow. It installs the mandatory terminal core, then pauses at each category (Code editors, DB tools, Dev environments, etc.) so you can selectively install exactly what you need.

---

## 🎨 Custom Themes

This environment runs on a unified, deeply customised dark mode aesthetic across the terminal and GUI editors.

- **Purple Fizz:** A dark purple theme with high contrast, popping syntax colors. Made for both VS Code and Zed (toned down for Zed)
- **Blue Slushii:** An icy, deep ink-blue theme with cyan accents (matches perfectly with my included WezTerm configuration).

Both themes were built from the ground up and are automatically symlinked into **VS Code** and **Zed** (fully compliant with Zed's `v0.2.0` theme engine, including transparent diagnostic backgrounds and custom gutter colors).

---

## 🪟 Window Management: [1Piece](https://app1piece.com/)

While Homebrew handles 99% of this stack, window management is handled by an incredibly powerful, highly customizable macOS app called `1Piece` which is to be installed manually (my personal recommendation).

**Why 1Piece?**

- **Performance:** It is very lightweight. Consuming just about 50-60mb of RAM and I personally never had a single issue using it daily.
- **Advanced Tiling:** Full hotkey support for standard halves, exact 1/3 & 2/3 thirds and 1/4 screen quarters.
- **Mouse Triggers:** You can bind actions directly to the trackpad. By hovering over any window's title bar, you can simply **scroll up** (swipe up) to instantly snap the app to full size, or **scroll down** (swipe down) to minimize it to the dock, both actions work on windows of any size.

---

## 📦 The Core Stack

### Terminal & Shell

- **[Zsh](https://www.zsh.org/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)**: The default macOS shell. Blazing fast & customisable paired with a highly informative prompt theme that utilizes an instant-prompt cache for zero latency startups.
- **[WezTerm](https://wezfurlong.org/wezterm/)**: A GPU-accelerated terminal emulator written in Rust. It is configured via Lua for endless customisability and handles translating macOS shortcut keys into native UNIX commands seamlessly (included in my .wezterm.lua config).
- **[eza](https://eza.rocks/)**: A modern, vibrant replacement for `ls` that includes color coding, git status integration, and native Nerd Font icon support.
- **[bat](https://github.com/sharkdp/bat)**: A `cat` clone with built-in syntax highlighting and Git integration, closely matched to my Wezterm's color palette.
- **[fd](https://github.com/sharkdp/fd)**: A simpler, significantly faster, and more user-friendly alternative to the traditional `find` command.
- **[fzf](https://github.com/junegunn/fzf)**: A general purpose command-line fuzzy finder. In this setup, it is deeply integrated with Zsh to provide instant, interactive previews for file navigation and history searches.
- **[pay-respects](https://github.com/iffse/pay-respects)**: A lightning fast, Rust based alternative to `thefuck` that instantly corrects typos in your terminal commands so you never lose your flow.

### Editors

- **[Zed](https://zed.dev/)**: A high performance code editor written in Rust. Configured here with native font ligatures disabled and a fully custom JSON theme for zero latency, distraction free editing.
- **[VS Code](https://code.visualstudio.com/)**: The daily driver. The `install.sh` script automatically bootstraps it with a curated list of extensions for C++, Vue, Markdown, and customised native indent-guide coloring, smooth cursor animations and a clean workspace.

### Dev Environment

- **[Homebrew](https://brew.sh/)**: The missing package manager for macOS. It powers the entire automated installation of this dotfiles repository. Clean install/uninstall with deep cleanup capabilities and countless options for both GUI apps and Formulae.
- **[nvm](https://github.com/nvm-sh/nvm)**: Node Version Manager. Allows for seamless switching between different Node.js environments. Configured to lazy-load in Zsh to keep terminal startup times virtually instant.
- **[pyenv](https://github.com/pyenv/pyenv)**: Python Version Management. Safely manage multiple active python versions without interfering with the system Python installation.
- **[difi](https://github.com/xguot/difi)**: An incredibly intuitive TUI (Terminal User Interface) for reviewing Git diffs interactively before committing code.

### Other tools included

- **[Mole](https://github.com/tw93/mole)**: An excellent MacOS clean-up utility that's interactive. Straight from your terminal.
- **[OpenMTP](https://github.com/ganeshrvel/openmtp)**: Best app to copy files to and fro from your Android device to your Mac.
- **[NextDNS](https://github.com/nextdns/nextdns/wiki/MacOS)**: My personal choice for highly customisable and private DNS service.
- **[Shottr](https://shottr.cc/)**: Best screenshot and annotation tool I've used. Has a free tier and a one-time purchase as well.
- **[Localsend](https://github.com/localsend/localsend)**: Send/Recieve files across your iOS, Adroid, Windows, MacOS and Linux.

```
Running the script is entirely OPTIONAL. I only made the script for easy
initialization of MacOS after a fresh install.
If you already have a functioning, customized system, you can simply go
through my files, copy and modify them as you like to your needs.
- blud0t
```
