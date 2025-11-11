# -------------------------------------
# NuGet Package Backup Manager (Advanced)
# Author: Mehdi Dimyadi (github.com/MEHDIMYADI)
# -------------------------------------

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Show-Menu {
    Clear-Host
    Write-Host "===================================="
    Write-Host "   NuGet Backup & Restore Manager"
    Write-Host "===================================="
    Write-Host "1. 📦 Backup NuGet Packages (ZIP)"
    Write-Host "2. 🔁 Restore from Backup (Select ZIP)"
    Write-Host "3. 🛠️ Set Custom NuGet Packages Path"
    Write-Host "4. 🛠️ Reset to Default NuGet Packages Path"	
    Write-Host "0. 🚪 Exit"
    Write-Host "===================================="
}

# Default NuGet packages path
$defaultPath = "$env:UserProfile\.nuget\packages"
$currentDir = Get-Location

# --- Folder picker dialog ---
function Choose-Folder {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select the target folder:"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }
    return $null
}

# --- Backup packages as ZIP ---
function Backup-Packages {
    if (!(Test-Path -Path $defaultPath)) {
        Write-Host "❌ NuGet folder not found: $defaultPath"
        return
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $zipFile = Join-Path $currentDir "NugetBackup_$timestamp.zip"

    Write-Host "`n📦 Creating ZIP backup from: $defaultPath"
    Write-Host "⏳ Please wait... (this may take a while for large package folders)"
    try {
        if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
        [IO.Compression.ZipFile]::CreateFromDirectory($defaultPath, $zipFile)
        Write-Host "✅ Backup completed successfully!"
        Write-Host "📁 Saved to: $zipFile"
    }
    catch {
        Write-Host "❌ Error during backup: $($_.Exception.Message)"
    }
}

# --- Restore packages from ZIP ---
function Restore-Packages {
    $backups = Get-ChildItem -Path $currentDir -Filter "NugetBackup_*.zip" | Sort-Object LastWriteTime -Descending

    if ($backups.Count -eq 0) {
        Write-Host "❌ No ZIP backups found in: $currentDir"
        return
    }

    Write-Host "`nAvailable Backups:"
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host "[$i] $($backups[$i].Name)"
    }

    $selection = Read-Host "Enter the number of the backup to restore"
    if ($selection -match '^\d+$' -and $selection -lt $backups.Count) {
        $selectedZip = $backups[$selection].FullName
        Write-Host "`n🔁 Restoring from: $selectedZip"
        Write-Host "⏳ Extracting to: $defaultPath"

        if (Test-Path $defaultPath) {
            Write-Host "⚠️ Existing NuGet packages will be overwritten."
        } else {
            New-Item -ItemType Directory -Force -Path $defaultPath | Out-Null
        }

        try {
            # Delete current contents to avoid duplication
            Remove-Item -Path "$defaultPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            [IO.Compression.ZipFile]::ExtractToDirectory($selectedZip, $defaultPath)
            Write-Host "✅ Restore completed successfully!"
        }
        catch {
            Write-Host "❌ Error during restore: $($_.Exception.Message)"
        }
    } else {
        Write-Host "❌ Invalid selection."
    }
}

# --- Set custom NuGet path ---
function Set-CustomPath {
    Write-Host "`n🛠️ Choose a new path for NuGet Packages..."
    $newPath = Choose-Folder
    if (-not $newPath) { Write-Host "❌ No path selected."; return }

    Write-Host "📁 Selected path: $newPath"
    Write-Host "Applying configuration..."

    $configFile = "$env:AppData\NuGet\NuGet.Config"
    [xml]$xml = Get-Content $configFile

    # --- Remove all extra <config> nodes ---
    $configs = @($xml.configuration.config)
    if ($configs.Count -gt 1) {
        for ($i = 1; $i -lt $configs.Count; $i++) {
            $xml.configuration.RemoveChild($configs[$i]) | Out-Null
        }
    }

    # --- Ensure there is at least one <config> node ---
    if (-not $xml.configuration.config) {
        $configNode = $xml.CreateElement("config")
        $xml.configuration.AppendChild($configNode) | Out-Null
    } else {
        $configNode = $xml.configuration.config[0]
    }

    # --- Update or add globalPackagesFolder ---
    $node = $configNode.add | Where-Object { $_.key -eq "globalPackagesFolder" }
    if ($node) {
        $node.value = $newPath
    } else {
        $addNode = $xml.CreateElement("add")
        $addNode.SetAttribute("key", "globalPackagesFolder")
        $addNode.SetAttribute("value", $newPath)
        $configNode.AppendChild($addNode) | Out-Null
    }

    $xml.Save($configFile)
    Write-Host "✅ Custom NuGet package path set successfully!"
}

# --- Reset NuGet path to default ---
function Set-DefaultPath {
    $configFile = "$env:AppData\NuGet\NuGet.Config"

    if (-Not (Test-Path $configFile)) {
        Write-Host "❌ NuGet.Config not found at $configFile"
        return
    }

    [xml]$xml = Get-Content $configFile

    if ($xml.configuration.config) {
        # Find <add key="globalPackagesFolder" /> and remove it
        $nodesToRemove = @($xml.configuration.config.add | Where-Object { $_.key -eq "globalPackagesFolder" })
        foreach ($node in $nodesToRemove) {
            $xml.configuration.config.RemoveChild($node) | Out-Null
        }

        $xml.Save($configFile)
        Write-Host "✅ NuGet path reset to default: $env:UserProfile\.nuget\packages"
    } else {
        Write-Host "⚠️ No custom globalPackagesFolder set. Already using default path."
    }
}

# --- Main loop ---
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (0-4)"
    switch ($choice) {
        '1' { Backup-Packages }
        '2' { Restore-Packages }
        '3' { Set-CustomPath }
		'4' { Set-DefaultPath }
        '0' { Write-Host "👋 Exiting..." }
        default { Write-Host "❗ Invalid option. Please try again." }
    }
    if ($choice -ne '0') {
        Write-Host "`nPress Enter to return to the menu or Ctrl+C to exit..."
        Read-Host
    }
} while ($choice -ne '0')
