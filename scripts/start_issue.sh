#!/bin/bash
# scripts/start_issue.sh
# version 1.0.1
# This script uses GitHub CLI to create and check out a branch linked to an issue.
# Usage: ./start_issue.sh <issue-number>

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Issue number is required.${NC}"
    echo "Usage: $0 <issue-number>"
    exit 1
fi

ISSUE="$1"

# Ensure user is logged in to GitHub CLI
if ! gh auth status &>/dev/null; then
    echo -e "${RED}❌ Error: You are not logged in to GitHub CLI. Run 'gh auth login' first.${NC}"
    exit 1
fi

# Check that issue exists
if ! gh issue view "$ISSUE" &>/dev/null; then
    echo -e "${RED}❌ Error: Issue #$ISSUE not found.${NC}"
    exit 1
fi

# Check for uncommitted changes before switching branches
echo "🔍 Checking for uncommitted changes..."
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Error: You have uncommitted changes. Please commit or stash them before proceeding.${NC}"
    git status -s
    exit 1
fi
echo -e "${GREEN}✅ No uncommitted changes found.${NC}"

# Pull the latest changes from the remote main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "🔄 Switching to main branch and pulling latest changes..."
    git checkout main
fi
git pull origin main

# Use GitHub CLI to create and link the branch
echo -e "🚀 Creating a branch for issue #$ISSUE using 'gh issue develop'..."
gh issue develop "$ISSUE" --checkout --base main

# Print branch creation status
NEW_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${GREEN}✅ Branch '$NEW_BRANCH' created and linked to issue #$ISSUE.${NC}"

# Get current GitHub username
CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null)
if [ -z "$CURRENT_USER" ]; then
    echo -e "${YELLOW}⚠️ Warning: Could not determine current GitHub username.${NC}"
else
    echo "👤 Current user: $CURRENT_USER"
    # Assign current user to the issue
    echo "📝 Assigning issue #$ISSUE to $CURRENT_USER..."
    if gh issue edit "$ISSUE" --add-assignee "$CURRENT_USER" 2>/dev/null; then
        echo -e "${GREEN}✅ Successfully assigned issue #$ISSUE to $CURRENT_USER.${NC}"
    else
        echo -e "${YELLOW}⚠️ Warning: Could not assign issue to $CURRENT_USER. You may not have permission or already be assigned.${NC}"
    fi
fi

# Remove "needs-triage" label if it exists
echo "🏷️ Checking for 'needs-triage' label..."
CURRENT_LABELS=$(gh issue view "$ISSUE" --json labels --jq '.labels[].name' 2>/dev/null)
if echo "$CURRENT_LABELS" | grep -q "needs-triage"; then
    echo "🗑️ Removing 'needs-triage' label from issue #$ISSUE..."
    if gh issue edit "$ISSUE" --remove-label "needs-triage" 2>/dev/null; then
        echo -e "${GREEN}✅ Successfully removed 'needs-triage' label.${NC}"
    else
        echo -e "${YELLOW}⚠️ Warning: Could not remove 'needs-triage' label. You may not have permission.${NC}"
    fi
else
    echo -e "${GREEN}✅ No 'needs-triage' label found on issue #$ISSUE.${NC}"
fi

# Call cleanup script to remove old branches (cross-platform path handling)
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
else
  SCRIPT_PATH="$0"
fi

# More robust cross-platform path resolution
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -W 2>/dev/null || pwd)"
# Alternative approach: use realpath if available, fallback to readlink/dirname
# SCRIPT_DIR="$(dirname "$(realpath "${SCRIPT_PATH}" 2>/dev/null || readlink -f "${SCRIPT_PATH}" 2>/dev/null || echo "${SCRIPT_PATH}")")"

CLEANUP_SCRIPT="$SCRIPT_DIR/cleanup_branches.sh"

if [ -f "$CLEANUP_SCRIPT" ]; then
    if [ -x "$CLEANUP_SCRIPT" ]; then
        echo -e "🧹 Running branch cleanup script..."
        if bash "$CLEANUP_SCRIPT"; then
            echo -e "${GREEN}✅ Branch cleanup completed successfully.${NC}"
        else
            echo -e "${YELLOW}⚠️ Warning: Branch cleanup script executed but returned an error.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Warning: cleanup_branches.sh found but not executable. Making it executable...${NC}"
        chmod +x "$CLEANUP_SCRIPT"
        echo -e "🧹 Running branch cleanup script..."
        if bash "$CLEANUP_SCRIPT"; then
            echo -e "${GREEN}✅ Branch cleanup completed successfully.${NC}"
        else
            echo -e "${YELLOW}⚠️ Warning: Branch cleanup script executed but returned an error.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️ Info: cleanup_branches.sh not found. Skipping branch cleanup.${NC}"
    echo -e "${YELLOW}💡 Tip: Create a cleanup_branches.sh script in the same directory to automatically clean up old branches.${NC}"
fi

echo -e "${GREEN}🎉 Issue #$ISSUE is ready for development!${NC}"