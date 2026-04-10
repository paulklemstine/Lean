# File organization script
# Sorts files from lean4/ into categorized directories at the root level

$base = "\\wsl.localhost\Ubuntu\home\raver1975\lean"
$source = Join-Path $base "lean4"

# Create target directories
$dirs = @("research", "sciam", "lean", "visual", "demo", "teams", "misc")
foreach ($d in $dirs) {
    $target = Join-Path $base $d
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        Write-Host "Created directory: $d"
    }
}

# Get all files recursively
$files = Get-ChildItem -Path $source -Recurse -File

$counts = @{
    research = 0
    sciam = 0
    lean = 0
    visual = 0
    demo = 0
    teams = 0
    misc = 0
}

foreach ($file in $files) {
    $name = $file.Name
    $ext = $file.Extension.ToLower()
    $relPath = $file.FullName.Substring($source.Length + 1)
    $relDir = Split-Path $relPath -Parent
    
    # Determine category based on priority order
    $category = $null
    
    # 1. Scientific American articles (highest specificity)
    if ($name -match "SciAm" -or $name -match "sciam" -or $name -match "scientific_american") {
        $category = "sciam"
    }
    # 2. Research papers
    elseif ($name -match "ResearchPaper" -or $name -match "research_paper" -or 
            ($relDir -match "papers" -and $name -match "research")) {
        $category = "research"
    }
    # 3. Team files (md files with team in name, not .lean files which are code)
    elseif (($name -match "Team" -or $name -match "team") -and $ext -ne ".lean") {
        $category = "teams"
    }
    # 4. Demo files
    elseif ($name -match "demo" -or $relDir -match "demos") {
        $category = "demo"
    }
    # 5. Visual files (SVG, PNG, JPG, etc.)
    elseif ($ext -in @(".svg", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".ico") -or
            $relDir -match "visuals") {
        $category = "visual"
    }
    # 6. Lean files
    elseif ($ext -eq ".lean") {
        $category = "lean"
    }
    # 7. Everything else
    else {
        $category = "misc"
    }
    
    # Create subdirectory structure preserving original hierarchy
    $targetDir = Join-Path $base $category
    if ($relDir) {
        $targetSubDir = Join-Path $targetDir $relDir
        if (-not (Test-Path $targetSubDir)) {
            New-Item -ItemType Directory -Path $targetSubDir -Force | Out-Null
        }
    } else {
        $targetSubDir = $targetDir
    }
    
    $targetPath = Join-Path $targetSubDir $name
    
    # Move file
    try {
        Move-Item -Path $file.FullName -Destination $targetPath -Force
        $counts[$category]++
    } catch {
        Write-Host "ERROR moving $relPath : $_"
    }
}

Write-Host ""
Write-Host "=== File Organization Complete ==="
Write-Host "Research papers: $($counts.research)"
Write-Host "Scientific American: $($counts.sciam)"
Write-Host "Lean files: $($counts.lean)"
Write-Host "Visuals: $($counts.visual)"
Write-Host "Demos: $($counts.demo)"
Write-Host "Teams: $($counts.teams)"
Write-Host "Misc: $($counts.misc)"
Write-Host "Total: $($counts.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum)"
