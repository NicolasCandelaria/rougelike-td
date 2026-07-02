Add-Type -AssemblyName System.Drawing

$bmp = New-Object System.Drawing.Bitmap(64, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
$g.Clear([System.Drawing.Color]::Transparent)

function C($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Brush($hex) { New-Object System.Drawing.SolidBrush (C $hex) }

# Palette: desert-tan armored tank, dark treads. Art faces UP.
$treadDark  = Brush '#3d3a32'
$treadLine  = Brush '#5a554a'
$hullOut    = Brush '#6e6449'
$hull       = Brush '#c2b280'
$hullShade  = Brush '#a89a6e'
$turretOut  = Brush '#5f563e'
$turret     = Brush '#b0a172'
$turretTop  = Brush '#cabb8a'
$barrelOut  = Brush '#4a453a'
$barrel     = Brush '#847c66'
$hatch      = Brush '#8f8258'

# Treads (left and right), y 10..56
$g.FillRectangle($treadDark, 10, 10, 11, 46)
$g.FillRectangle($treadDark, 43, 10, 11, 46)
# Tread rungs
for ($y = 12; $y -le 52; $y += 5) {
    $g.FillRectangle($treadLine, 11, $y, 9, 2)
    $g.FillRectangle($treadLine, 44, $y, 9, 2)
}

# Hull between the treads, with outline
$g.FillRectangle($hullOut, 19, 12, 26, 42)
$g.FillRectangle($hull, 21, 14, 22, 38)
# Front glacis shading (top) and rear deck (bottom)
$g.FillRectangle($hullShade, 21, 14, 22, 5)
$g.FillRectangle($hullShade, 21, 46, 22, 6)

# Barrel pointing up from turret center (cy ~= 36)
$g.FillRectangle($barrelOut, 28, 2, 8, 22)
$g.FillRectangle($barrel, 30, 4, 4, 20)
# Muzzle brake
$g.FillRectangle($barrelOut, 26, 2, 12, 5)
$g.FillRectangle($barrel, 28, 3, 8, 3)

# Turret (circle) sitting slightly rear of center
$g.FillEllipse($turretOut, 21, 24, 22, 22)
$g.FillEllipse($turret, 23, 26, 18, 18)
$g.FillEllipse($turretTop, 26, 29, 12, 12)
# Hatch dot
$g.FillEllipse($hatch, 29, 32, 6, 6)

$g.Dispose()
$out = Join-Path $PSScriptRoot '..\assets\sprites\enemy_tank.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "saved $out"
