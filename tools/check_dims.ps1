Add-Type -AssemblyName System.Drawing
foreach ($n in @('enemy_tank','enemy_grunt','enemy_runner','enemy_swarm')) {
    $p = Join-Path $PSScriptRoot "..\assets\sprites\$n.png"
    $img = [System.Drawing.Image]::FromFile((Resolve-Path $p))
    Write-Output ("{0}: {1}x{2}" -f $n, $img.Width, $img.Height)
    $img.Dispose()
}
