#!/usr/bin/env bash

DOTFILES_DIR="$HOME/Developer/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ======================
# 0. Cloning my dotfiles
# ======================
GITHUB_URL="https://github.com/blud0t/dotfiles.git"
CODEBERG_URL="https://codeberg.org/blud0t/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}📂 Dotfiles directory not found. Cloning repository...${NC}"
    mkdir -p "$HOME/Developer"
    
    # Check for git and wait for installation if missing
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️ Git is not installed. Starting installation of Command Line Tools...${NC}"
        xcode-select --install
        
        echo -e "${CYAN}⏳ Waiting for macOS Command Line Tools installation to complete...${NC}"
        echo -e "${CYAN}(Please complete the installation in the window that just appeared. The script will automatically resume when finished.)${NC}"
        
        # Git install verification loop
        while ! command -v git &> /dev/null; do
            sleep 5
        done
        
        echo -e "${GREEN}✅ Command Line Tools installed successfully! Resuming script...${NC}"
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

# symlink - Helper function
symlink_file() {
    local src=$1
    local dest=$2

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo -e "${YELLOW}📦 Backing up existing $dest to $BACKUP_DIR${NC}"
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -s "$src" "$dest"
    echo -e "${GREEN}✅ Linked $dest -> $src${NC}"
}

# ==================
# 1. Package arrays
# ==================
TAPS=("romkatv/powerlevel10k" "timescam/homebrew-tap")

# Core (Mandatory for all)
CORE_FORMULAE=("bat" "eza" "fd" "fzf" "romkatv/powerlevel10k/powerlevel10k" "zsh-autosuggestions" "zsh-syntax-highlighting")
CORE_CASKS=("wezterm")

# Everyday use (Minimal)
EVERYDAY_CASKS=("mullvad-browser" "ungoogled-chromium" "vlc" "pearcleaner" "shottr" "localsend" "notepadnext" "discord")

# Developer tools categories
EDITORS_CASKS=("visual-studio-code" "zed")
DEV_ENV_FORMULAE=("cmake" "ninja" "just" "nvm" "pyenv" "coreutils" "difi" "timescam/homebrew-tap/pay-respects" "tree" "zsh-autocomplete")
DB_FORMULAE=("mongodb-atlas-cli" "mongosh" "sqlite")
ADVANCED_FORMULAE=("hugo" "mole" "p7zip" "scrcpy" "nextdns")
ADVANCED_CASKS=("android-platform-tools" "openmtp" "tailscale-app" "utm")

# Lists populated based on user choice
INSTALL_FORMULAE=("${CORE_FORMULAE[@]}")
INSTALL_CASKS=("${CORE_CASKS[@]}")

# ====================
# 2. Interactive Menu
# ====================
echo -e "How would you like to setup this Mac?"
echo -e "  ${CYAN}1) Minimal${NC}    (Core CLI, Fonts, Everyday use.)"
echo -e "  ${CYAN}2) Developer${NC}  (Everything: IDEs, configs, dev envs, DBs, VMs.)"
echo -e "  ${CYAN}3) Custom${NC}     (Custom installation.)"

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
        INSTALL_CASKS+=("${EVERYDAY_CASKS[@]}" "${EDITORS_CASKS[@]}" "${ADVANCED_CASKS[@]}")
        INSTALL_FORMULAE+=("${DEV_ENV_FORMULAE[@]}" "${DB_FORMULAE[@]}" "${ADVANCED_FORMULAE[@]}")
        echo -e "\n${GREEN}→ Selected: Developer${NC}"
        break
    elif [ "$PATH_CHOICE" == "3" ]; then
        echo -e "\n${YELLOW}--- Custom installation ---${NC}"
        
        read -p "Install Everyday apps (Browsers, VLC, Shottr, Discord)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_CASKS+=("${EVERYDAY_CASKS[@]}"); fi

        read -p "Install Code editors (VS Code, Zed)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_CASKS+=("${EDITORS_CASKS[@]}"); fi

        read -p "Install Dev environments (Pyenv, NVM, CMake, Ninja, Just)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_FORMULAE+=("${DEV_ENV_FORMULAE[@]}"); fi

        read -p "Install Database tools (MongoDB, SQLite)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then INSTALL_FORMULAE+=("${DB_FORMULAE[@]}"); fi

        read -p "Install Advanced tools (UTM, Tailscale, Android Tools, Hugo)? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then 
            INSTALL_FORMULAE+=("${ADVANCED_FORMULAE[@]}")
            INSTALL_CASKS+=("${ADVANCED_CASKS[@]}")
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

echo -e "\n${BLUE}📦 Installing formulae...${NC}"
brew install "${INSTALL_FORMULAE[@]}"

echo -e "\n${BLUE}📦 Installing casks...${NC}"
brew install --cask "${INSTALL_CASKS[@]}"

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
symlink_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
symlink_file "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

# ===========
# 6. VS Code
# ===========
if [[ " ${INSTALL_CASKS[*]} " =~ " visual-studio-code " ]] || [ -d "/Applications/Visual Studio Code.app" ]; then
    echo -e "\n${BLUE}📝 Configuring VS Code...${NC}"
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
    mkdir -p "$VSCODE_USER_DIR"

    symlink_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

    # Theme
    VSCODE_EXT_DIR="$HOME/.vscode/extensions"
    mkdir -p "$VSCODE_EXT_DIR"
    symlink_file "$DOTFILES_DIR/vscode/purpletheme" "$VSCODE_EXT_DIR/blud0t.purple-fizz-1.0.0"

    echo -e "${CYAN}🧩 Installing VS Code extensions...${NC}"
    
    # Locate the code CLI
    CODE_CMD=""
    if command -v code &> /dev/null; then
        CODE_CMD="code"
    elif [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
        CODE_CMD="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    fi

    if [ -n "$CODE_CMD" ]; then
        while IFS= read -r ext || [ -n "$ext" ]; do
            [[ -z "$ext" || "$ext" == \#* ]] && continue
            "$CODE_CMD" --install-extension "$ext" --force
        done < "$DOTFILES_DIR/vscode/extensions.txt"
    else
        echo -e "${YELLOW}⚠️ Could not locate VS Code CLI. Open VS Code and install extensions manually.${NC}"
    fi
fi

# =======
# 7. Zed
# =======
if [[ " ${INSTALL_CASKS[*]} " =~ " zed " ]] || [ -d "$HOME/.config/zed" ]; then
    echo -e "\n${BLUE}⚡ Configuring Zed...${NC}"
    mkdir -p "$HOME/.config/zed/themes"
    symlink_file "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
    symlink_file "$DOTFILES_DIR/zed/themes/blueslushii.json" "$HOME/.config/zed/themes/blueslushii.json"
    symlink_file "$DOTFILES_DIR/zed/themes/purplefizz.json" "$HOME/.config/zed/themes/purplefizz.json"
fi

# ==============
# 8. Finalising
# ==============
echo -e "\n${GREEN}🎉 All done! Your macOS environment is fully set up.${NC}"
echo -e "${YELLOW}⚠️ FINAL STEPS:${NC}"
echo -e "${CYAN}1. Completely quit this default Terminal.${NC}"
echo -e "${CYAN}2. Open 'WezTerm' from your Applications folder.${NC}"
echo -e "${CYAN}3. Follow the Powerlevel10k configuration wizard that automatically appears.${NC}"
echo -e "${CYAN}4. Use 'p10k configure' in your Wezterm to start it manually.${NC}\n"