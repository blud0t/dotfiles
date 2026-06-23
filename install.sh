#!/usr/bin/env bash

DOTFILES_DIR="/tmp/macos_dotfiles_setup"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ======================
# 0. Cloning my dotfiles
# ======================
GITHUB_URL="https://github.com/blud0t/dotfiles.git"
CODEBERG_URL="https://codeberg.org/blud0t/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}📂 Dotfiles directory not found. Cloning repository...${NC}"
    
    # Check for git and wait for installation if missing
    if ! command -v git &> /dev/null; then
        # Headless git installation
        echo -e "${YELLOW}⚠️ Git is not installed. Starting headless installation of Command Line Tools...${NC}"
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        CLI_UPDATE=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')

        if [ -n "$CLI_UPDATE" ]; then
            echo -e "${CYAN}⏳ Installing: $CLI_UPDATE (This will take a few minutes)${NC}"
            softwareupdate -i "$CLI_UPDATE" --verbose
            rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
            echo -e "${GREEN}✅ Command Line Tools installed successfully! Resuming script...${NC}"
        else
            echo -e "${YELLOW}⚠️ Headless install failed. Falling back to GUI prompt...${NC}"
            xcode-select --install
            
            # Fallback git installation
            while ! command -v git &> /dev/null; do
                sleep 5
            done
            echo -e "${GREEN}✅ Command Line Tools installed successfully! Resuming script...${NC}"
        fi
    fi
    
    if git clone "$GITHUB_URL" "$DOTFILES_DIR"; then
        echo -e "${GREEN}✅ Repository cloned successfully from GitHub.${NC}"
    else
        echo -e "${YELLOW}⚠️ GitHub clone failed. Cloning from Codeberg...${NC}"
        git clone "$CODEBERG_URL" "$DOTFILES_DIR"
        echo -e "${GREEN}✅ Repository cloned successfully from Codeberg.${NC}"
    fi
else
    echo -e "${GREEN}✅ Dotfiles directory found at $DOTFILES_DIR${NC}"
fi

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${CYAN}   Starting dotfiles bootstrap script   ${NC}"
echo -e "${BLUE}==========================================${NC}\n"

mkdir -p "$BACKUP_DIR"

# Switched to standard copy flow instead of symlinks
copy_file() {
    local src=$1
    local dest=$2

    # Legacy symlinks cleanup
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo -e "${YELLOW}📦 Backing up existing $dest to $BACKUP_DIR${NC}"
        mv "$dest" "$BACKUP_DIR/"
    fi

    cp -R "$src" "$dest"
    echo -e "${GREEN}✅ Copied $src -> $dest${NC}"
}

# ==================
# 1. Package arrays
# ==================
TAPS=("romkatv/powerlevel10k" "dail8859/notepadnext" "vorssaint/tap")

# Core (Mandatory for all paths)
CORE_FORMULAE=("bat" "eza" "fd" "fzf" "p7zip" "tlrc" "tree" "romkatv/powerlevel10k/powerlevel10k" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-autocomplete")
CORE_CASKS=("wezterm")

# Everyday use (Minimal path)
EVERYDAY_CASKS=("mullvad-browser" "ungoogled-chromium" "floorp" "vlc" "pearcleaner" "shottr" "localsend" "notepadnext" "discord" "notesnook" "zotero" "bitwarden" "ente-auth" "keka" "rustdesk" "vorssaint")

# Developer tools
EDITORS_CASKS=("visual-studio-code" "zed")
DEV_ENV_FORMULAE=("allure" "cmake" "coreutils" "deno" "difi" "fresh-editor" "hugo" "just" "ninja" "node" "nvm" "pyenv")
DB_FORMULAE=("mongodb-atlas-cli" "mongosh" "sqlite")

# Power Tools (Media, VMs, Android, Networking)
POWER_FORMULAE=("ffmpeg" "mole" "nextdns" "scrcpy" "yt-dlp")
POWER_CASKS=("android-platform-tools" "openmtp" "utm")

# Lists populated based on user choice
INSTALL_FORMULAE=("${CORE_FORMULAE[@]}")
INSTALL_CASKS=("${CORE_CASKS[@]}")

# ====================
# 2. Interactive Menu
# ====================
echo -e "How would you like to setup this Mac?"
echo -e "  ${CYAN}1) Minimal${NC}    (Core CLI, Fonts, Browsers, Notes, Everyday use.)"
echo -e "  ${CYAN}2) Developer${NC}  (Everything: IDEs, Dev Envs, DBs, Android Tools, VMs, Media.)"
echo -e "  ${CYAN}3) Custom${NC}     (Choose exact categories to install.)"

while true; do
    read -p "Select a path [1/2/3] or 'q' to quit: " PATH_CHOICE

    if [[ "$PATH_CHOICE" =~ ^[Qq]$ ]]; then
        echo -e "\n${YELLOW}🛑 Installation aborted by user. Exiting...${NC}"
        exit 0
    elif [ "$PATH_CHOICE" == "1" ]; then
        INSTALL_CASKS+=("${EVERYDAY_CASKS[@]}")
        echo -e "\n${GREEN}→ Selected: Minimal${NC}"
        break
    elif [ "$PATH_CHOICE" == "2" ]; then
        INSTALL_CASKS+=("${EVERYDAY_CASKS[@]}" "${EDITORS_CASKS[@]}" "${POWER_CASKS[@]}")
        INSTALL_FORMULAE+=("${DEV_ENV_FORMULAE[@]}" "${DB_FORMULAE[@]}" "${POWER_FORMULAE[@]}")
        echo -e "\n${GREEN}→ Selected: Developer${NC}"
        break
    elif [ "$PATH_CHOICE" == "3" ]; then
        echo -e "\n${YELLOW}--- Custom installation ---${NC}"
        
        read -p "Install everyday apps (Browsers, Media, Notes, Auth)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_CASKS+=("${EVERYDAY_CASKS[@]}"); fi

        read -p "Install Code editors (VS Code and Zed)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_CASKS+=("${EDITORS_CASKS[@]}"); fi
        
        # Isolated Cursor installation to avoid extensions installation conflict
        read -p "Install AI Code editor (Cursor)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_CASKS+=("cursor"); fi

        read -p "Install Dev environments (Node, Python, CMake, Hugo, etc.)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_FORMULAE+=("${DEV_ENV_FORMULAE[@]}"); fi

        read -p "Install Database tools (MongoDB, SQLite)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_FORMULAE+=("${DB_FORMULAE[@]}"); fi

        read -p "Install Power tools (VMs, Android ADB, FFmpeg, nextdns)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then 
            INSTALL_FORMULAE+=("${POWER_FORMULAE[@]}")
            INSTALL_CASKS+=("${POWER_CASKS[@]}")
        fi
        break
    else
        echo -e "${YELLOW}⚠️ Invalid choice. Please choose 1, 2, 3, or 'q'.${NC}"
    fi
done

# ===============================
# 3. Install Homebrew & Packages
# ===============================
echo -e "\n${BLUE}🍺 Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e "${GREEN}✅ Homebrew is already installed.${NC}"
fi

echo -e "\n${BLUE}📦 Tapping repositories...${NC}"
for tap in "${TAPS[@]}"; do
    brew tap "$tap"
done
# Looped formula installations to rectify skips
echo -e "\n${BLUE}📦 Installing formulae...${NC}"
for formula in "${INSTALL_FORMULAE[@]}"; do
    brew install "$formula" || echo -e "${YELLOW}⚠️ Failed to install formula: $formula. Skipping...${NC}"
done
# Looped cask installations to rectify skips
echo -e "\n${BLUE}📦 Installing casks...${NC}"
for cask in "${INSTALL_CASKS[@]}"; do
    brew install --cask "$cask" || echo -e "${YELLOW}⚠️ Failed to install cask: $cask. Skipping...${NC}"
done

# ========
# 4. Font
# ========
echo -e "\n${BLUE}🔤 Installing custom fonts...${NC}"
cp "$DOTFILES_DIR/fonts/VertexMonoNF-Regular.ttf" "$HOME/Library/Fonts/"
echo -e "${GREEN}✅ Vertex Mono NF installed.${NC}"

# ====================================
# 5. Terminal Configs (Zsh & WezTerm)
# ====================================
echo -e "\n${BLUE}🐚 Configuring terminal...${NC}"
copy_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
copy_file "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

# Checking path integrity before code editor installation
CURSOR_ONLY_MODE=false
if [ -d "/Applications/Cursor.app" ] && [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo -e "\n${YELLOW}⚠️ Notice: Cursor detected, but standard VS Code is missing.${NC}"
    echo -e "${CYAN}→ The 'code' command is likely overwritten by Cursor.${NC}"
    CURSOR_ONLY_MODE=true
fi

# ===========
# 6. VS Code
# ===========
if [ "$CURSOR_ONLY_MODE" = false ] && { [[ " ${INSTALL_CASKS[*]} " =~ " visual-studio-code " ]] || [ -d "/Applications/Visual Studio Code.app" ]; }; then
    echo -e "\n${BLUE}📝 Configuring VS Code...${NC}"
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
    mkdir -p "$VSCODE_USER_DIR"

    copy_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

    # Theme
    VSCODE_EXT_DIR="$HOME/.vscode/extensions"
    mkdir -p "$VSCODE_EXT_DIR"
    copy_file "$DOTFILES_DIR/vscode/purpletheme" "$VSCODE_EXT_DIR/blud0t.purple-fizz-1.0.0"
    
    # Extensions
    echo -e "${CYAN}🧩 Installing VS Code extensions...${NC}"
    while IFS= read -r ext || [ -n "$ext" ]; do
        ext=$(echo "$ext" | tr -d '\r' | xargs)
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        code --install-extension "$ext" --force
    done < "$DOTFILES_DIR/vscode/extensions.txt"
fi

# ===========
# 6.5 Cursor
# ===========
if [[ " ${INSTALL_CASKS[*]} " =~ " cursor " ]] || [ -d "/Applications/Cursor.app" ]; then
    echo -e "\n${BLUE}📝 Configuring Cursor...${NC}"
    CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
    mkdir -p "$CURSOR_USER_DIR"

    copy_file "$DOTFILES_DIR/vscode/settings.json" "$CURSOR_USER_DIR/settings.json"

    # Cursor's isolated copied files & Theme
    CURSOR_EXT_DIR="$HOME/.cursor/extensions"
    mkdir -p "$CURSOR_EXT_DIR"
    copy_file "$DOTFILES_DIR/vscode/purpletheme" "$CURSOR_EXT_DIR/blud0t.purple-fizz-1.0.0"
    
    # Extensions
    echo -e "${CYAN}🧩 Installing Cursor extensions...${NC}"
    while IFS= read -r ext || [ -n "$ext" ]; do
        ext=$(echo "$ext" | tr -d '\r' | xargs)
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        cursor --install-extension "$ext" --force
    done < "$DOTFILES_DIR/vscode/extensions.txt"
fi
# ==========================================================

# =======
# 7. Zed
# =======
if [[ " ${INSTALL_CASKS[*]} " =~ " zed " ]] || [ -d "$HOME/.config/zed" ]; then
    echo -e "\n${BLUE}⚡ Configuring Zed...${NC}"
    mkdir -p "$HOME/.config/zed/themes"
    copy_file "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
    copy_file "$DOTFILES_DIR/zed/themes/blueslushii.json" "$HOME/.config/zed/themes/blueslushii.json"
    copy_file "$DOTFILES_DIR/zed/themes/purplefizz.json" "$HOME/.config/zed/themes/purplefizz.json"
fi

# ==============
# 8. Finalising
# ==============

echo -e "\n${BLUE}📦 Installing pay-respects natively...${NC}"
curl -sSfL https://raw.githubusercontent.com/iffse/pay-respects/main/install.sh | sh

echo -e "\n${BLUE}🧹 Cleaning up Homebrew leftovers...${NC}"
brew cleanup --prune=all
echo -e "${GREEN}✅ Homebrew clean up complete.${NC}"

echo -e "\n${BLUE}🗑️  Removing temporary dotfiles repository...${NC}"
rm -rf "$DOTFILES_DIR"
echo -e "${GREEN}✅ Temporary files deleted.${NC}"

echo -e "\n${CYAN}⏳ Installation complete! Pausing for 10 seconds to review...${NC}"
sleep 10

echo -e "\n${GREEN}🎉 All done! Your macOS environment is fully set up.${NC}"
echo -e "${CYAN}Launching WezTerm to initialize Powerlevel10k and closing this terminal...${NC}"
open -a WezTerm
osascript -e 'tell application "Terminal" to quit'
