# Crops generated card icons to a center square and resizes to 128x128.
# Usage: powershell -File tools/make_icons.ps1 -SourceDir <folder with icon_*.png>
param([string]$SourceDir = ".")

Add-Type -AssemblyName System.Drawing
$outDir = Join-Path $PSScriptRoot "..\assets\sprites\icons"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

foreach ($f in Get-ChildItem $SourceDir -Filter "icon_*.png") {
    $src = [System.Drawing.Image]::FromFile($f.FullName)
    $side = [Math]::Min($src.Width, $src.Height)
    $x = [int](($src.Width - $side) / 2)
    $y = [int](($src.Height - $side) / 2)

    $dst = New-Object System.Drawing.Bitmap 128, 128
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, 128, 128),
        (New-Object System.Drawing.Rectangle $x, $y, $side, $side),
        [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $src.Dispose()

    $out = Join-Path $outDir $f.Name
    $dst.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $dst.Dispose()
    Write-Output ("{0} -> 128x128" -f $f.Name)
}
