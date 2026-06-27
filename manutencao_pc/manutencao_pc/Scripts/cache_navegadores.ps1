Write-Host "===== LIMPEZA DE CACHE DE NAVEGADORES =====" -ForegroundColor Cyan
Write-Host "Se o Chrome, Edge ou Firefox estiverem abertos, alguns arquivos podem ficar em uso."
Write-Host ""

function Limpar-Pasta($caminho, $nome) {
    if (Test-Path $caminho) {
        try {
            Remove-Item "$caminho\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cache limpo: $nome" -ForegroundColor Green
        } catch {
            Write-Host "Nao foi possivel limpar tudo em: $nome (arquivos em uso)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "$nome nao encontrado neste perfil." -ForegroundColor DarkGray
    }
}

# Google Chrome
Limpar-Pasta "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" "Chrome (Cache)"
Limpar-Pasta "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache" "Chrome (Code Cache)"

# Microsoft Edge
Limpar-Pasta "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache" "Edge (Cache)"
Limpar-Pasta "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache" "Edge (Code Cache)"

# Mozilla Firefox (pode ter varios perfis)
$pastaPerfis = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $pastaPerfis) {
    $perfis = Get-ChildItem $pastaPerfis -Directory -ErrorAction SilentlyContinue
    foreach ($perfil in $perfis) {
        Limpar-Pasta (Join-Path $perfil.FullName "cache2") "Firefox ($($perfil.Name))"
    }
} else {
    Write-Host "Firefox nao encontrado neste usuario." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Limpeza de cache de navegadores concluida." -ForegroundColor Green
