#!/bin/bash
set -e

echo "========================================="
echo "Testing Workflow Logic Locally"
echo "========================================="
echo ""

# Test 1: Version Detection
echo "Test 1: Detecting Godot version from project.godot..."
GODOT_VERSION=$(grep 'config/features' project.godot | grep -o '[0-9]\+\.[0-9]\+' | head -n 1)

if [ -z "$GODOT_VERSION" ]; then
  echo "❌ ERROR: Could not detect Godot version from project.godot"
  exit 1
fi

echo "✅ Detected version: $GODOT_VERSION"
echo ""

# Test 2: Game Name Detection
echo "Test 2: Detecting game name..."
GAME_NAME=$(grep 'config/name=' project.godot | sed 's/config\/name="\(.*\)"/\1/' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo "godot-game")
echo "✅ Game name: $GAME_NAME"
echo ""

# Test 3: Check if GitHub URLs exist
echo "Test 3: Checking if Godot $GODOT_VERSION exists on GitHub..."
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
echo "Checking: $GODOT_URL"

if curl -f -s -I "$GODOT_URL" > /dev/null 2>&1; then
  echo "✅ Godot executable URL is valid"
else
  echo "❌ ERROR: Godot $GODOT_VERSION not found on GitHub"
  echo "URL: $GODOT_URL"
  exit 1
fi
echo ""

echo "Test 4: Checking if export templates exist..."
TEMPLATES_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
echo "Checking: $TEMPLATES_URL"

if curl -f -s -I "$TEMPLATES_URL" > /dev/null 2>&1; then
  echo "✅ Export templates URL is valid"
else
  echo "❌ ERROR: Export templates for Godot $GODOT_VERSION not found"
  echo "URL: $TEMPLATES_URL"
  exit 1
fi
echo ""

# Test 5: Check export presets
echo "Test 5: Checking export presets..."
declare -A platforms=(
  ["windows"]="Windows Desktop|windows|${GAME_NAME}.exe"
  ["linux"]="Linux|linux|${GAME_NAME}.x86_64"
  ["web"]="Web|web|index.html"
  ["macos"]="macOS|macos|${GAME_NAME}.app"
)

platform_count=0
for platform in "${!platforms[@]}"; do
  IFS='|' read -ra PLATFORM_INFO <<< "${platforms[$platform]}"
  preset_name="${PLATFORM_INFO[0]}"
  
  if grep -q "platform=\"$preset_name\"" export_presets.cfg; then
    echo "  ✅ Found preset for $platform ($preset_name)"
    platform_count=$((platform_count + 1))
  fi
done

if [ $platform_count -eq 0 ]; then
  echo "❌ ERROR: No export presets found!"
  exit 1
fi

echo ""
echo "========================================="
echo "✅ All tests passed!"
echo "========================================="
echo "Summary:"
echo "  - Godot Version: $GODOT_VERSION"
echo "  - Game Name: $GAME_NAME"
echo "  - Export Presets Found: $platform_count"
echo "  - GitHub URLs: Valid"
echo ""
echo "The workflow should work when you push it!"
