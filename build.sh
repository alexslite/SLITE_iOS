#!/bin/bash

# Slite iOS Build Script
# This script helps automate the build process for the Slite iOS app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Slite"
SCHEME_NAME="Slite"
WORKSPACE_PATH="Slite.xcodeproj"
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/Slite.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
EXPORT_OPTIONS_PLIST="ExportOptions.plist"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Slite iOS Build Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_step "Checking build requirements..."
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode command line tools not found. Please install Xcode."
        exit 1
    fi
    
    # Check Xcode version
    XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2 | cut -d'.' -f1)
    if [ "$XCODE_VERSION" -lt 15 ]; then
        print_error "Xcode 15.0 or later is required. Current version: $(xcodebuild -version | grep "Xcode" | cut -d' ' -f2)"
        exit 1
    fi
    
    # Check if project exists
    if [ ! -d "$WORKSPACE_PATH" ]; then
        print_error "Project not found at $WORKSPACE_PATH"
        exit 1
    fi
    
    print_success "Requirements check passed"
}

clean_build() {
    print_step "Cleaning build directory..."
    
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    print_success "Build directory cleaned"
}

build_project() {
    print_step "Building project..."
    
    xcodebuild \
        -project "$WORKSPACE_PATH" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -derivedDataPath "$BUILD_DIR/derived" \
        clean build
    
    if [ $? -eq 0 ]; then
        print_success "Project built successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

archive_project() {
    print_step "Archiving project..."
    
    xcodebuild \
        -project "$WORKSPACE_PATH" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -archivePath "$ARCHIVE_PATH" \
        archive
    
    if [ $? -eq 0 ]; then
        print_success "Project archived successfully"
    else
        print_error "Archive failed"
        exit 1
    fi
}

export_ipa() {
    print_step "Exporting IPA..."
    
    # Create export options plist if it doesn't exist
    if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
        create_export_options
    fi
    
    xcodebuild \
        -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"
    
    if [ $? -eq 0 ]; then
        print_success "IPA exported successfully to $EXPORT_PATH"
    else
        print_error "Export failed"
        exit 1
    fi
}

create_export_options() {
    print_step "Creating export options plist..."
    
    cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF
    
    print_success "Export options plist created. Please update YOUR_TEAM_ID with your actual team ID."
}

run_tests() {
    print_step "Running tests..."
    
    xcodebuild \
        -project "$WORKSPACE_PATH" \
        -scheme "$SCHEME_NAME" \
        -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
        test
    
    if [ $? -eq 0 ]; then
        print_success "Tests passed"
    else
        print_error "Tests failed"
        exit 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  clean       Clean build directory"
    echo "  build       Build the project"
    echo "  archive     Archive the project"
    echo "  export      Export IPA from archive"
    echo "  test        Run tests"
    echo "  all         Clean, build, archive, and export"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build        # Build the project"
    echo "  $0 all          # Complete build process"
    echo "  $0 test         # Run tests only"
}

# Main script
main() {
    print_header
    
    case "${1:-help}" in
        "clean")
            check_requirements
            clean_build
            ;;
        "build")
            check_requirements
            build_project
            ;;
        "archive")
            check_requirements
            archive_project
            ;;
        "export")
            check_requirements
            export_ipa
            ;;
        "test")
            check_requirements
            run_tests
            ;;
        "all")
            check_requirements
            clean_build
            build_project
            archive_project
            export_ipa
            print_success "Complete build process finished successfully!"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"