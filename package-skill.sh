#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "  h3yun-dev-assistant Package Tool"
echo "========================================"
echo

# Check if required files exist
if [[ ! -f "skill/SKILL.md" ]]; then
    echo "[ERROR] skill/SKILL.md not found!"
    exit 1
fi

if [[ ! -f "skill/CODING_STANDARDS.md" ]]; then
    echo "[WARNING] CODING_STANDARDS.md not found, will package without coding standards"
    echo
fi

# Create temp directory
echo "Step 1/4: Creating package directory..."
rm -rf "dist"
mkdir -p "dist"

# Copy files to package directory
echo "Step 2/4: Copying files..."
cp "skill/SKILL.md" "dist/SKILL.md"
if [[ -f "skill/CODING_STANDARDS.md" ]]; then cp "skill/CODING_STANDARDS.md" "dist/CODING_STANDARDS.md"; fi

# Create ZIP archive
echo "Step 3/4: Creating ZIP archive..."
rm -f "h3yun-dev-assistant.zip"
(cd "dist" && zip -qr "../h3yun-dev-assistant.zip" .)

# Clean up temp directory
echo "Step 4/4: Cleaning up..."
rm -rf "dist"

echo
echo "========================================"
echo "  Package Complete!"
echo "  File: $(pwd)/h3yun-dev-assistant.zip"
echo "========================================"
echo
