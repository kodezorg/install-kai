#!/bin/bash

# Setup script for GitHub CLI (gh) + Kodez kai + Cloud CLIs
# - Ensures gh is installed (via brew install gh if missing)
# - Guides the user through gh auth login
# - **Always** runs `brew uninstall kai` + `brew untap kodezorg/homebrew-kai` first (clean install)
# - Taps kodezorg/homebrew-kai and installs kai
# - Ensures Azure CLI (az) is installed and user runs `az login`
# - Ensures AWS CLI is installed (and optionally configured)
#
# IMPORTANT: Do NOT host this on SharePoint if you want a working one-liner.
# SharePoint sharing links return 403 to curl. Use a raw URL instead:
#
# Recommended (GitHub Gist raw URL example):
#   bash <(curl -fsSL "https://gist.githubusercontent.com/YOUR_USER/XXXXXX/raw/setup-kai.sh")
#
# From this repo (if made available via raw.githubusercontent.com):
#   bash <(curl -fsSL "https://raw.githubusercontent.com/kodezorg/kodez-ai-platform/main/scripts/setup-kai.sh")
#
# Local (after cloning the repo):
#   bash scripts/setup-kai.sh
#
# To test locally:
#   bash scripts/setup-kai.sh


set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
    exit 1
}

# Ensure Homebrew is available
ensure_brew() {
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is required but not installed. Install it from https://brew.sh/"
    fi
}

# Check if gh CLI is installed
check_gh_installed() {
    if command -v gh &> /dev/null; then
        local gh_version
        gh_version=$(gh --version | head -n1)
        log_success "GitHub CLI is installed: $gh_version"
        return 0
    else
        log_warn "GitHub CLI (gh) is not installed."
        return 1
    fi
}

# Install gh via Homebrew
install_gh() {
    log_info "Installing GitHub CLI via Homebrew..."
    brew install gh
    log_success "GitHub CLI installed successfully"
}

# Check authentication status
check_auth_status() {
    if gh auth status &> /dev/null; then
        log_success "Already authenticated with GitHub"
        return 0
    else
        log_warn "Not authenticated with GitHub"
        return 1
    fi
}

# Guide user through login (blocks until they complete or cancel)
perform_login() {
    echo ""
    log_info "GitHub authentication is required (the kai tap is private)."
    echo ""
    read -p "Press Enter to start 'gh auth login' (or Ctrl-C to cancel)..." -r
    echo ""

    log_info "Starting GitHub authentication..."
    gh auth login

    # Re-verify after login attempt
    if gh auth status &> /dev/null; then
        log_success "Authentication successful"
    else
        log_error "Authentication did not complete. Please run 'gh auth login' and try again."
    fi
}

# Check if kai is already installed
check_kai_installed() {
    if command -v kai &> /dev/null; then
        local kai_version
        kai_version=$(kai --version 2>/dev/null || echo "kai (version unknown)")
        log_success "kai is already installed: $kai_version"
        return 0
    else
        return 1
    fi
}

# Tap the private kai Homebrew repository
tap_kai_repo() {
    log_info "Tapping kodezorg/homebrew-kai..."
    brew tap kodezorg/homebrew-kai
    log_success "Tapped kodezorg/homebrew-kai"
}

# Install kai via Homebrew
install_kai() {
    log_info "Installing kai..."
    brew install kai
    log_success "kai installed successfully"
}

# Force remove any previous kai installation and untap the repo
# This ensures a clean install (useful when iterating on the tap/package)
cleanup_previous_kai() {
    log_info "Cleaning up any previous kai installation..."
    brew uninstall --force kai 2>/dev/null || true
    brew untap kodezorg/homebrew-kai 2>/dev/null || true
    log_success "Previous kai installation and tap removed"
}

# ============================================
# NodeJS
# ============================================
check_node_installed() {
    if command -v node &> /dev/null; then
        local node_version
        node_version=$(node --version 2>/dev/null)
        log_success "Node.js is installed: $node_version"
        return 0
    else
        log_warn "Node.js is not installed."
        return 1
    fi
}

install_node() {
    log_info "Installing Node.js via Homebrew..."
    brew install node
    log_success "Node.js installed successfully"
}

# ============================================
# Azure CLI
# ============================================

# Check if Azure CLI is installed
check_az_installed() {
    if command -v az &> /dev/null; then
        local az_version
        az_version=$(az version --output tsv 2>/dev/null | head -n1 || az --version | head -n1)
        log_success "Azure CLI is installed: $az_version"
        return 0
    else
        log_warn "Azure CLI (az) is not installed."
        return 1
    fi
}



# Install Azure CLI via Homebrew
install_az() {
    log_info "Installing Azure CLI via Homebrew..."
    brew install azure-cli
    log_success "Azure CLI installed successfully"
}

# Check if user is logged into Azure
check_az_logged_in() {
    if az account show &> /dev/null; then
        local account_name
        account_name=$(az account show --query name -o tsv 2>/dev/null || echo "active subscription")
        log_success "Already logged into Azure ($account_name)"
        return 0
    else
        log_warn "Not logged into Azure"
        return 1
    fi
}

# Guide user through az login
perform_az_login() {
    echo ""
    log_info "Azure login is recommended for working with Azure resources."
    echo ""
    read -p "Press Enter to start 'az login' (or Ctrl-C to cancel)..." -r
    echo ""

    log_info "Starting Azure authentication (this will open a browser)..."
    az login

    # Re-verify after login attempt
    if az account show &> /dev/null; then
        log_success "Azure login successful"
    else
        log_warn "Azure login did not complete or no subscription is selected."
        log_info "You can run 'az login' or 'az account set --subscription <id>' later."
    fi
}

# ============================================
# AWS CLI
# ============================================

# Check if AWS CLI is installed
check_aws_installed() {
    if command -v aws &> /dev/null; then
        local aws_version
        aws_version=$(aws --version 2>/dev/null | head -n1)
        log_success "AWS CLI is installed: $aws_version"
        return 0
    else
        log_warn "AWS CLI is not installed."
        return 1
    fi
}

# Install AWS CLI via Homebrew
install_aws() {
    log_info "Installing AWS CLI via Homebrew..."
    brew install awscli
    log_success "AWS CLI installed successfully"
}

# Check if AWS credentials are configured
check_aws_configured() {
    if aws sts get-caller-identity &> /dev/null; then
        local identity
        identity=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "configured identity")
        log_success "AWS credentials are configured ($identity)"
        return 0
    else
        log_warn "AWS credentials are not configured"
        return 1
    fi
}

# Optionally guide the user through AWS configuration
perform_aws_configure() {
    echo ""
    log_info "AWS credentials are not configured."
    echo ""
    read -p "Run 'aws configure' now to set up credentials? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Starting AWS configuration..."
        aws configure
        log_success "AWS configuration step complete"
    else
        log_info "You can configure AWS later with: aws configure"
        log_info "Or use: aws configure sso  (for SSO / IAM Identity Center)"
    fi
}

# Main
main() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Kodez CLI Tools Setup${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    ensure_brew

    # GitHub CLI + kai
    if ! check_gh_installed; then
        install_gh
    fi

    if ! check_auth_status; then
        perform_login
    fi

    # Force a clean slate before (re)installing kai
    cleanup_previous_kai

    # Now safe to access the private tap
    tap_kai_repo

    if ! check_kai_installed; then
        install_kai
    fi

    # NodeJS
    if ! check_node_installed; then
        install_node
    fi

    # Azure CLI
    if ! check_az_installed; then
        install_az
    fi

    if ! check_az_logged_in; then
        perform_az_login
    fi

    # AWS CLI
    if ! check_aws_installed; then
        install_aws
    fi

    if ! check_aws_configured; then
        perform_aws_configure
    fi

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    log_info "Quick checks:"
    echo "  kai --help"
    echo "  gh --version"
    echo "  az account show"
    echo "  aws sts get-caller-identity"
    echo ""
}

main "$@"
