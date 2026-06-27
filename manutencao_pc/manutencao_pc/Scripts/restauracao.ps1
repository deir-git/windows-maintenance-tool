Write-Host "===== CRIAR PONTO DE RESTAURACAO =====" -ForegroundColor Cyan
Write-Host "Isso cria um ponto para desfazer alteracoes do sistema, caso algo de errado."
Write-Host ""

try {
    Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Antes da Manutencao PC" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "Ponto de restauracao criado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "Nao foi possivel criar o ponto de restauracao." -ForegroundColor Red
    Write-Host "Motivos comuns: Protecao do Sistema desativada para esta unidade, ou o" -ForegroundColor Yellow
    Write-Host "Windows so permite 1 ponto a cada 24 horas nesta edicao." -ForegroundColor Yellow
}
