# Battery Health Dashboard

A sleek and easy-to-use PowerShell script that analyzes your Windows battery report and generates a beautiful HTML dashboard. It calculates your battery's current health percentage, estimates remaining runtime based on your system's history, and presents the data in an easy-to-read format.

## Features

- 📊 **Visual Dashboard**: Displays battery health in a clean, modern ring chart.
- 🔋 **Health Calculation**: Compares current full charge capacity against the original design capacity.
- ⏱️ **Runtime Estimation**: Estimates full charge runtime based on recent battery history.
- 🚀 **Auto-Launch**: Automatically opens the generated HTML report in your default browser.

## How to Run

### Run directly via web (using `irm`)

If this script is hosted online (e.g., on GitHub), you can run it directly from PowerShell without downloading it manually:

```powershell
irm https://raw.githubusercontent.com/aziziyahya563/gg-battery-health/main/index.ps1 | iex
```

### Run locally

1. Download or clone this repository.
2. Open PowerShell.
3. Navigate to the directory containing the script.
4. Run the script:
   ```powershell
   .\index.ps1
   ```

> **Note**: You may need to bypass the execution policy if you are running scripts locally for the first time. You can do this temporarily for your session by running:
> `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
