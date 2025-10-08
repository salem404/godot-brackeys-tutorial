# Test Workflow Logic Locally
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Testing Workflow Logic Locally" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Version Detection
Write-Host "Test 1: Detecting Godot version from project.godot..." -ForegroundColor Yellow
$content = Get-Content "project.godot" -Raw
if ($content -match 'config/features=PackedStringArray\("(\d+\.\d+)"') {
    $GODOT_VERSION = $matches[1]
    Write-Host "✅ Detected version: $GODOT_VERSION" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Could not detect Godot version from project.godot" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Game Name Detection
Write-Host "Test 2: Detecting game name..." -ForegroundColor Yellow
if ($content -match 'config/name="([^"]+)"') {
    $GAME_NAME = $matches[1].ToLower() -replace ' ', '-'
    Write-Host "✅ Game name: $GAME_NAME" -ForegroundColor Green
} else {
    $GAME_NAME = "godot-game"
    Write-Host "✅ Game name (default): $GAME_NAME" -ForegroundColor Green
}
Write-Host ""

# Test 3: Check if GitHub URLs exist
Write-Host "Test 3: Checking if Godot $GODOT_VERSION exists on GitHub..." -ForegroundColor Yellow
$GODOT_URL = "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION-stable/Godot_v$GODOT_VERSION-stable_linux.x86_64.zip"
Write-Host "Checking: $GODOT_URL"

try {
    $response = Invoke-WebRequest -Uri $GODOT_URL -Method Head -ErrorAction Stop
    Write-Host "✅ Godot executable URL is valid (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Godot $GODOT_VERSION not found on GitHub" -ForegroundColor Red
    Write-Host "URL: $GODOT_URL" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Check export templates
Write-Host "Test 4: Checking if export templates exist..." -ForegroundColor Yellow
$TEMPLATES_URL = "https://github.com/godotengine/godot/releases/download/$GODOT_VERSION-stable/Godot_v$GODOT_VERSION-stable_export_templates.tpz"
Write-Host "Checking: $TEMPLATES_URL"

try {
    $response = Invoke-WebRequest -Uri $TEMPLATES_URL -Method Head -ErrorAction Stop
    Write-Host "✅ Export templates URL is valid (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Export templates for Godot $GODOT_VERSION not found" -ForegroundColor Red
    Write-Host "URL: $TEMPLATES_URL" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 5: Check export presets
Write-Host "Test 5: Checking export presets..." -ForegroundColor Yellow
$presets_content = Get-Content "export_presets.cfg" -Raw

$platforms = @{
    "windows" = "Windows Desktop"
    "linux" = "Linux"
    "web" = "Web"
    "macos" = "macOS"
}

$platform_count = 0
foreach ($platform in $platforms.Keys) {
    $preset_name = $platforms[$platform]
    if ($presets_content -match "platform=`"$preset_name`"") {
        Write-Host "  ✅ Found preset for $platform ($preset_name)" -ForegroundColor Green
        $platform_count++
    }
}

if ($platform_count -eq 0) {
    Write-Host "❌ ERROR: No export presets found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ All tests passed!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Summary:"
Write-Host "  - Godot Version: $GODOT_VERSION"
Write-Host "  - Game Name: $GAME_NAME"
Write-Host "  - Export Presets Found: $platform_count"
Write-Host "  - GitHub URLs: Valid"
Write-Host ""
Write-Host "The workflow should work when you push it! 🚀" -ForegroundColor Green
