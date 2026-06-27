Write-Host "===== TESTE DE VELOCIDADE DE INTERNET =====" -ForegroundColor Cyan
Write-Host "Baixando arquivo de teste (20 MB), aguarde..."
Write-Host ""

$url = "https://speed.cloudflare.com/__down?bytes=20000000"
$out = Join-Path $env:TEMP "speedtest_tmp.bin"

try {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    $sw.Stop()

    $sizeBytes = (Get-Item $out).Length
    Remove-Item $out -Force -ErrorAction SilentlyContinue

    $seconds = $sw.Elapsed.TotalSeconds
    $mbps = [math]::Round((($sizeBytes * 8) / $seconds) / 1000000, 2)
    $mbBaixados = [math]::Round($sizeBytes / 1MB, 2)

    Write-Host "Dados baixados: $mbBaixados MB"
    Write-Host "Tempo: $([math]::Round($seconds,2)) segundos"
    Write-Host "Velocidade de download estimada: $mbps Mbps" -ForegroundColor Green
} catch {
    Write-Host "Nao foi possivel completar o teste. Verifique sua conexao com a internet." -ForegroundColor Red
}

Write-Host ""
Write-Host "Latencia (ping) para o Google DNS:"
try {
    Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction Stop |
        Select-Object Address, ResponseTime | Format-Table -AutoSize
} catch {
    Write-Host "Nao foi possivel medir a latencia." -ForegroundColor Red
}
