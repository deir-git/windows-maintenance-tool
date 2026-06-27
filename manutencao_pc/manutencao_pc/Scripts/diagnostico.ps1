Write-Host "===== DIAGNOSTICO DE CPU, MEMORIA E PROCESSOS =====" -ForegroundColor Cyan
Write-Host ""

$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
$os = Get-CimInstance Win32_OperatingSystem
$memUsedPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
$memUsedGB  = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB), 2)
$memTotalGB = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)

Write-Host "CPU em uso agora: $cpu%"
Write-Host "Memoria em uso: $memUsedGB GB de $memTotalGB GB ($memUsedPct%)"
Write-Host ""

Write-Host "Top 10 processos por uso de CPU:" -ForegroundColor Yellow
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 `
    Name, Id, @{N='CPU(s)';E={[math]::Round($_.CPU,1)}}, @{N='MemoriaMB';E={[math]::Round($_.WS/1MB,1)}} |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Top 10 processos por uso de Memoria:" -ForegroundColor Yellow
Get-Process | Sort-Object WS -Descending | Select-Object -First 10 `
    Name, Id, @{N='MemoriaMB';E={[math]::Round($_.WS/1MB,1)}} |
    Format-Table -AutoSize

if ($cpu -gt 80) {
    Write-Host "AVISO: o uso de CPU esta alto agora. Veja a lista acima para achar o processo." -ForegroundColor Red
}
if ($memUsedPct -gt 85) {
    Write-Host "AVISO: o uso de memoria esta alto. Considere fechar programas que nao esta usando." -ForegroundColor Red
}
