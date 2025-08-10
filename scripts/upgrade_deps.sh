# scripts/upgrade_deps.sh
# This script is used to upgrade dependencies in the project.
# version: 2.0
#!/bin/bash

set -e  # Exit on any error

# Colors for better output visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to handle errors
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Command failed with exit code $exit_code at line $line_number"
    print_error "Please check the output above for more details"
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

echo "==========================================="
echo "    Dependency Upgrade Script v2.0"
echo "==========================================="
echo ""

# Check if required tools are installed
print_step "Checking required tools..."

if ! command -v ncu &> /dev/null; then
    print_error "npm-check-updates (ncu) is not installed"
    print_error "Please install it globally: npm install -g npm-check-updates"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    print_error "pnpm is not installed"
    print_error "Please install it: npm install -g pnpm"
    exit 1
fi

print_success "All required tools are available"
echo ""

# Step 1: Show current package.json status
print_step "Checking current dependencies..."
if [ -f "package.json" ]; then
    print_success "Found package.json"
    echo "Current dependencies that can be updated:"
    ncu || {
        print_warning "Could not check for outdated dependencies"
    }
else
    print_error "package.json not found in current directory"
    exit 1
fi
echo ""

# Step 2: Update package.json dependencies
print_step "Updating package.json dependencies using npm-check-updates..."
if ncu -u; then
    print_success "Dependencies updated in package.json"
else
    print_error "Failed to update dependencies"
    exit 1
fi
echo ""

# Step 3: Install the updated dependencies
print_step "Installing updated dependencies with pnpm..."
if pnpm install; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    print_error "This might be due to:"
    print_error "  - Network connectivity issues"
    print_error "  - Package conflicts"
    print_error "  - Insufficient disk space"
    print_error "  - Permission issues"
    exit 1
fi
echo ""

# Step 4: Run the build process
print_step "Building the project to ensure compatibility..."
if pnpm build; then
    print_success "Project built successfully"
else
    print_error "Build failed after dependency update"
    print_error "This might indicate:"
    print_error "  - Breaking changes in updated dependencies"
    print_error "  - TypeScript compilation errors"
    print_error "  - Missing dependencies"
    print_warning "You may need to:"
    print_warning "  - Check the build output above for specific errors"
    print_warning "  - Review breaking changes in updated packages"
    print_warning "  - Update your code to match new API changes"
    exit 1
fi
echo ""

# Step 5: Run tests
print_step "Running tests to verify everything works correctly..."
if pnpm test; then
    print_success "All tests passed"
else
    print_error "Tests failed after dependency update"
    print_error "This might indicate:"
    print_error "  - Breaking changes affecting functionality"
    print_error "  - Test dependencies incompatibilities"
    print_error "  - Changed behavior in updated packages"
    print_warning "You may need to:"
    print_warning "  - Review test failures above"
    print_warning "  - Update tests to match new behavior"
    print_warning "  - Fix code issues revealed by updated dependencies"
    exit 1
fi
echo ""

echo "==========================================="
print_success "Dependency upgrade completed successfully!"
echo "==========================================="
echo ""
print_step "Summary of actions performed:"
echo "  ✓ Checked and updated package.json dependencies"
echo "  ✓ Installed updated packages"
echo "  ✓ Verified project builds correctly"
echo "  ✓ Confirmed all tests pass"
echo ""
print_warning "Next steps (recommended):"
echo "  - Review the changes in package.json"
echo "  - Test the application manually"
echo "  - Commit the updated dependencies"
echo "  - Consider updating lock files in version control"
