#!/bin/bash

# Break process on any error
set -e 

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# FUNCTIONS ---------------------------------------

# Output functions
info() { echo -e "${GREEN}ℹ️ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
step() { echo -e "${BLUE}🔹 $1${NC}"; }

# Install by current package manager
install_packages() {
    local packages=$1
    info "Install packages: $packages"
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y $packages
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm $packages
    else
        error "Current package manager is not supported"
        exit 1
    fi
}

# PROGRAM ---------------------------------------

# Distro detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    info "Detected distro: $OS"
else
    error "Can't determine Linux distro"
    exit 1
fi

# Установка базовых пакетов
step "1. Install basic packages ..."
base_packages="which wget curl git zsh fontconfig make
tldr ripgrep bat fd fzf btop duf dust tree eza zoxide"
install_packages "$base_packages"

# Install and setup Oh My Zsh
step "2. Install Zsh and Oh My Zsh..."
if ! command -v zsh &> /dev/null; then
    error "Zsh don't installed!"
    exit 1
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Install Oh My Zsh..."
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    info "Oh My Zsh already installed"
fi

step "3. Install and setup chezmoi..."
if ! command -v chezmoi &> /dev/null; then
    info "Install chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply
else
    info "Chezmoi already installed"
fi

# Установка Miniconda
step "4. Install miniconda..."
if ! command -v conda &> /dev/null; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $HOME/miniconda
    rm miniconda.sh
    
    # Инициализация conda
    eval "$($HOME/miniconda/bin/conda shell.zsh hook)"
    conda init
else
    info "Conda installed already"
fi