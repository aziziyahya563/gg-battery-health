# Customization Options
$authorName = "Azizi Yahya"

# Detect simplified OS Name (e.g. "Windows 11" or "Windows 10")
$rawOs = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
if ($rawOs -match "(Windows\s+\d+)") {
    $osName = $Matches[1]
} else {
    $osName = "Windows"
}

# Define output locations
$xmlPath = "$env:TEMP\battery_report.xml"
$htmlPath = "$env:USERPROFILE\Desktop\Battery_Health_Report.html"

# Generate Windows XML battery report
powercfg /batteryreport /xml /output $xmlPath | Out-Null

if (-not (Test-Path $xmlPath)) {
    Write-Host "Error: Unable to generate battery report." -ForegroundColor Red
    return
}

# Parse XML Data
[xml]$xmlData = Get-Content $xmlPath
$battery = $xmlData.BatteryReport.Batteries.Battery | Select-Object -First 1

if (-not $battery) {
    Write-Host "No active battery detected on this system." -ForegroundColor Yellow
    return
}

# Extract Capacities
$designCap = [double]$battery.DesignCapacity
$fullCap = [double]$battery.FullChargeCapacity
$batteryName = if ($battery.Name) { $battery.Name } else { "Standard Battery" }
$manufacturer = if ($battery.Manufacturer) { $battery.Manufacturer } else { "OEM" }

# Calculate Health Percentage
if ($designCap -gt 0) {
    $healthPercent = [math]::Round(($fullCap / $designCap) * 100, 1)
    if ($healthPercent -gt 100) { $healthPercent = 100 }
} else {
    $healthPercent = 0
}

# Calculate capacity in Wh
$fullWh = [math]::Round($fullCap / 1000, 1)
$designWh = [math]::Round($designCap / 1000, 1)

# Determine status colors
if ($healthPercent -ge 80) {
    $statusText = "Good / Healthy"
    $statusColor = "#10b981" # Green
} elseif ($healthPercent -ge 60) {
    $statusText = "Fair (Degraded)"
    $statusColor = "#f59e0b" # Orange
} else {
    $statusText = "Poor (Service Recommended)"
    $statusColor = "#ef4444" # Red
}

$timestamp = (Get-Date).ToString("MMM dd, yyyy | hh:mm tt")

# Build Dashboard HTML
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Battery Health Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .card-container {
            max-width: 440px;
            width: 100%;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
            padding: 32px;
            border: 1px solid #e2e8f0;
        }
        .header { text-align: center; margin-bottom: 24px; }
        .header h1 { font-size: 1.4rem; font-weight: 700; color: #0f172a; }
        .header p { color: #64748b; font-size: 0.85rem; margin-top: 4px; }
        
        .health-ring-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 24px;
        }
        .ring {
            width: 130px;
            height: 130px;
            border-radius: 50%;
            border: 8px solid $statusColor;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            margin-bottom: 12px;
        }
        .ring-score { font-size: 2.2rem; font-weight: 800; color: $statusColor; }
        .ring-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.05em; color: #64748b; }
        .status-badge {
            background-color: $statusColor;
            color: #ffffff;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 4px 14px;
            border-radius: 999px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
            margin-bottom: 24px;
        }
        .stat-box {
            background-color: #f1f5f9;
            padding: 14px;
            border-radius: 10px;
            text-align: center;
        }

        .stat-title { font-size: 0.75rem; color: #64748b; font-weight: 600; text-transform: uppercase; }
        .stat-value { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin-top: 4px; }
        .stat-note { font-size: 0.72rem; color: #64748b; margin-top: 2px; }

        .footer {
            text-align: center;
            font-size: 0.75rem;
            color: #94a3b8;
            border-top: 1px solid #e2e8f0;
            padding-top: 16px;
            line-height: 1.5;
        }
        .credits {
            color: #64748b;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="card-container">
        <div class="header">
            <h1>Battery Health Overview</h1>
            <p>$manufacturer $batteryName</p>
        </div>

        <div class="health-ring-container">
            <div class="ring">
                <span class="ring-score">$healthPercent%</span>
                <span class="ring-label">Capacity</span>
            </div>
            <div class="status-badge">$statusText</div>
        </div>

        <div class="stats-grid">

            <div class="stat-box">
                <div class="stat-title">Current Max</div>
                <div class="stat-value">$fullWh Wh</div>
                <div class="stat-note">Full Charge Capacity</div>
            </div>
            <div class="stat-box">
                <div class="stat-title">Original Max</div>
                <div class="stat-value">$designWh Wh</div>
                <div class="stat-note">Design Capacity</div>
            </div>
        </div>

        <div class="footer">
            Generated on $timestamp &bull; $osName<br>
            <span class="credits">Script made by $authorName</span>
        </div>
    </div>
</body>
</html>
"@

# Write HTML File
$htmlContent | Out-File -FilePath $htmlPath -Encoding utf8

# Cleanup temporary XML
Remove-Item $xmlPath -ErrorAction SilentlyContinue

# Open generated file in default web browser
Start-Process $htmlPath