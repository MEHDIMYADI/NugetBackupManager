# 💾 NuGet Package Backup Manager (PowerShell + BAT)

## 🚀 Overview

This tool lets you **backup**, **restore**, and **change** the location of your local NuGet packages folder.  
It’s perfect for developers who reinstall Windows or Visual Studio frequently and don’t want to re-download all NuGet packages.

You can now **run it with a single double-click** using the included `.bat` launcher — no PowerShell configuration needed!

---

## 🧩 Features

| Feature | Description |
|----------|--------------|
| 📦 **Backup (ZIP)** | Compresses `.nuget\packages` into a timestamped ZIP archive. |
| 🔁 **Restore (Select)** | Lets you pick a ZIP file to restore your NuGet cache. |
| 🛠️ **Set Custom Path** | Set a new global packages folder (e.g., `D:\NugetPackages`). |
| 🛠️ **Set Default Path** | Sets the global packages folder to default. |

---

## 🧰 Files

| File | Description |
|------|--------------|
| `NugetBackupManager.ps1` | Main PowerShell script (core logic) |
| `NugetBackupManager.bat` | Launcher for Windows (run this one) |

---

## ⚙️ Installation

1. **Download or clone** this repository:
   ```bash
   git clone https://github.com/MEHDIMYADI/NugetBackupManager.git
   cd NugetBackupManager

2. Make sure both files are in the same folder:
	NugetBackupManager.ps1
	NugetBackupManager.bat
	
3. Run the tool:

✅ Just double-click NugetBackupManager.bat

💻 Or manually run: powershell -ExecutionPolicy Bypass -File .\NugetBackupManager.ps1



