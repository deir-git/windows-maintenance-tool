@echo off
:: =====================================================================
::  MANUTENCAO DE PC - Script com menu interativo
::  Funcoes: rede, velocidade de internet, arquivos do sistema, disco,
::  diagnostico de CPU/memoria, limpeza de temporarios e de cache de
::  navegadores, desempenho, ponto de restauracao e relatorio final.
::
::  Como usar:
::    1. Extraia TODO o conteudo do ZIP (precisa da pasta "Scripts" do
::       lado deste arquivo)
::    2. De um clique duplo neste .bat (ele pede admin sozinho)
:: =====================================================================

setlocal enabledelayedexpansion
chcp 1252 >nul
title Manutencao de PC - Menu
color 0A

:: ---------------------------------------------------------------------
:: Verifica se esta rodando como Administrador, senao se reabre elevado
:: ---------------------------------------------------------------------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ---------------------------------------------------------------------
:: Confere se a pasta Scripts (com os .ps1) esta presente
:: ---------------------------------------------------------------------
if not exist "%~dp0Scripts" (
    echo.
    echo AVISO: a pasta "Scripts" nao foi encontrada ao lado deste .bat!
    echo As opcoes de diagnostico, velocidade, cache e restauracao nao vao funcionar.
    echo Extraia TODO o conteudo do ZIP antes de rodar o script.
    echo.
    pause
)
set "PSDIR=%~dp0Scripts"

:: ---------------------------------------------------------------------
:: Prepara pasta e arquivo de log
:: ---------------------------------------------------------------------
set "LOGDIR=%~dp0Logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "TIMESTAMP=%date%_%time%"
set "TIMESTAMP=%TIMESTAMP::=-%"
set "TIMESTAMP=%TIMESTAMP:/=-%"
set "TIMESTAMP=%TIMESTAMP: =_%"
set "TIMESTAMP=%TIMESTAMP:,=%"
set "LOGFILE=%LOGDIR%\manutencao_%TIMESTAMP%.log"
echo Sessao de manutencao iniciada em %date% %time% > "%LOGFILE%"

:: =======================================================================
:MENU
cls
echo ===============================================================
echo                  MANUTENCAO DE COMPUTADOR
echo ===============================================================
echo  Log desta sessao: %LOGFILE%
echo ---------------------------------------------------------------
echo   1. Diagnosticar e reparar REDE (sem internet, wifi lento, etc)
echo   2. Teste de velocidade de internet
echo   3. Verificar/reparar arquivos do sistema (SFC / DISM)
echo   4. Verificar disco em busca de erros (CHKDSK)
echo   5. Diagnostico de CPU, memoria e processos (PC lento)
echo   6. Limpar arquivos temporarios e liberar espaco
echo   7. Limpar cache dos navegadores (Chrome/Edge/Firefox)
echo   8. Otimizar desempenho
echo   9. Criar ponto de restauracao do sistema
echo  10. Executar TUDO (1 a 9 + relatorio final)
echo  11. Ver informacoes do sistema
echo  12. Gerar relatorio em .txt (foto atual do sistema)
echo   0. Sair
echo ===============================================================
set /p OPCAO="Escolha uma opcao e tecle Enter: "

if "%OPCAO%"=="1"  (call :REDE & goto MENU)
if "%OPCAO%"=="2"  (call :VELOCIDADE & goto MENU)
if "%OPCAO%"=="3"  (call :SISTEMA & goto MENU)
if "%OPCAO%"=="4"  (call :DISCO & goto MENU)
if "%OPCAO%"=="5"  (call :DIAGNOSTICO & goto MENU)
if "%OPCAO%"=="6"  (call :LIMPEZA & goto MENU)
if "%OPCAO%"=="7"  (call :LIMPACACHE & goto MENU)
if "%OPCAO%"=="8"  (call :PERFORMANCE & goto MENU)
if "%OPCAO%"=="9"  (call :RESTAURACAO & goto MENU)
if "%OPCAO%"=="10" (call :TUDO & goto MENU)
if "%OPCAO%"=="11" (call :INFO & goto MENU)
if "%OPCAO%"=="12" (call :RELATORIO & goto MENU)
if "%OPCAO%"=="0" goto SAIR

echo.
echo Opcao invalida, tente novamente.
pause
goto MENU

:: =======================================================================
:REDE
cls
echo ===== DIAGNOSTICO E REPARO DE REDE =====
echo Rede - inicio %time% >> "%LOGFILE%"
echo.
echo [1/6] Liberando endereco IP atual...
ipconfig /release >> "%LOGFILE%" 2>&1
echo [2/6] Renovando endereco IP...
ipconfig /renew >> "%LOGFILE%" 2>&1
echo [3/6] Limpando cache de DNS...
ipconfig /flushdns >> "%LOGFILE%" 2>&1
echo [4/6] Reiniciando catalogo Winsock...
netsh winsock reset >> "%LOGFILE%" 2>&1
echo [5/6] Reiniciando pilha TCP/IP...
netsh int ip reset >> "%LOGFILE%" 2>&1
echo [6/6] Testando conectividade com a internet...
ping -n 4 8.8.8.8
echo.
echo Concluido! Para o reset de Winsock/TCP-IP fazer efeito total,
echo pode ser necessario REINICIAR o computador.
echo Rede - fim %time% >> "%LOGFILE%"
pause
goto :eof

:: =======================================================================
:VELOCIDADE
cls
if not exist "%PSDIR%\velocidade.ps1" (
    echo Arquivo Scripts\velocidade.ps1 nao encontrado.
    pause
    goto :eof
)
echo Velocidade - inicio %time% >> "%LOGFILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSDIR%\velocidade.ps1"
echo Velocidade - fim %time% >> "%LOGFILE%"
echo.
pause
goto :eof

:: =======================================================================
:SISTEMA
cls
echo ===== VERIFICACAO DE ARQUIVOS DO SISTEMA =====
echo Isso pode demorar varios minutos, nao feche esta janela.
echo Sistema - inicio %time% >> "%LOGFILE%"
echo.
echo [1/2] Executando SFC (verifica arquivos do Windows)...
sfc /scannow
echo.
echo [2/2] Executando DISM (repara a imagem do Windows)...
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo Verificacao concluida. Veja o resultado acima.
echo Sistema - fim %time% >> "%LOGFILE%"
pause
goto :eof

:: =======================================================================
:DISCO
cls
echo ===== VERIFICACAO DE DISCO (CHKDSK) =====
echo.
set /p DRIVE="Digite a letra do disco a verificar (ex: C, sem dois pontos): "
echo Disco %DRIVE%: - inicio %time% >> "%LOGFILE%"
echo.
echo Verificando erros no disco %DRIVE%:...
chkdsk %DRIVE%: /scan
echo.
set /p REPARO="Quer agendar reparo completo no proximo reinicio? (S/N): "
if /i "%REPARO%"=="S" (
    echo Y| chkdsk %DRIVE%: /f /r
    echo Reparo agendado. Reinicie o computador para o CHKDSK rodar.
)
echo Disco %DRIVE%: - fim %time% >> "%LOGFILE%"
pause
goto :eof

:: =======================================================================
:DIAGNOSTICO
cls
if not exist "%PSDIR%\diagnostico.ps1" (
    echo Arquivo Scripts\diagnostico.ps1 nao encontrado.
    pause
    goto :eof
)
echo Diagnostico - inicio %time% >> "%LOGFILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSDIR%\diagnostico.ps1"
echo Diagnostico - fim %time% >> "%LOGFILE%"
echo.
pause
goto :eof

:: =======================================================================
:LIMPEZA
cls
echo ===== LIMPEZA DE ARQUIVOS TEMPORARIOS =====
echo Limpeza - inicio %time% >> "%LOGFILE%"

for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "[math]::Round((Get-PSDrive %SystemDrive:~0,1%).Free/1MB)"`) do set "FREE_BEFORE_MB=%%F"

echo.
echo [1/5] Limpando pasta Temp do usuario...
del /f /s /q "%temp%\*.*" >nul 2>&1
for /d %%i in ("%temp%\*") do rd /s /q "%%i" >nul 2>&1

echo [2/5] Limpando pasta Temp do Windows...
del /f /s /q "%windir%\Temp\*.*" >nul 2>&1
for /d %%i in ("%windir%\Temp\*") do rd /s /q "%%i" >nul 2>&1

echo [3/5] Limpando arquivos do Prefetch...
del /f /q "%windir%\Prefetch\*.*" >nul 2>&1

echo [4/5] Esvaziando a Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo [5/5] Abrindo Liberador de Espaco em Disco do Windows...
cleanmgr /d %SystemDrive% >nul 2>&1

for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "[math]::Round((Get-PSDrive %SystemDrive:~0,1%).Free/1MB)"`) do set "FREE_AFTER_MB=%%F"

echo.
echo Limpeza concluida! Espaco em disco liberado.
echo Limpeza - fim %time% >> "%LOGFILE%"
pause
goto :eof

:: =======================================================================
:LIMPACACHE
cls
if not exist "%PSDIR%\cache_navegadores.ps1" (
    echo Arquivo Scripts\cache_navegadores.ps1 nao encontrado.
    pause
    goto :eof
)
echo.
echo Feche o Chrome, Edge e Firefox antes de continuar, se possivel.
pause
echo Cache navegadores - inicio %time% >> "%LOGFILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSDIR%\cache_navegadores.ps1"
echo Cache navegadores - fim %time% >> "%LOGFILE%"
echo.
pause
goto :eof

:: =======================================================================
:PERFORMANCE
cls
echo ===== OTIMIZACAO DE DESEMPENHO (PC LENTO) =====
echo Performance - inicio %time% >> "%LOGFILE%"
echo.
echo [1/3] Programas que iniciam junto com o Windows:
echo (para desabilitar algum, use o Gerenciador de Tarefas, aba Inicializar)
wmic startup get caption,command
echo.
echo [2/3] Ativando plano de energia de Alto Desempenho...
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
echo Plano de energia ajustado (se disponivel neste PC).
echo.
echo [3/3] Otimizando as unidades de disco (pode demorar)...
defrag %SystemDrive% /O
echo.
echo Otimizacao concluida!
echo Performance - fim %time% >> "%LOGFILE%"
pause
goto :eof

:: =======================================================================
:RESTAURACAO
cls
if not exist "%PSDIR%\restauracao.ps1" (
    echo Arquivo Scripts\restauracao.ps1 nao encontrado.
    pause
    goto :eof
)
echo Restauracao - inicio %time% >> "%LOGFILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSDIR%\restauracao.ps1"
echo Restauracao - fim %time% >> "%LOGFILE%"
echo.
pause
goto :eof

:: =======================================================================
:INFO
cls
echo ===== INFORMACOES DO SISTEMA =====
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
echo.
echo Espaco em disco:
wmic logicaldisk get caption,freespace,size
echo.
pause
goto :eof

:: =======================================================================
:RELATORIO
cls
echo ===== GERANDO RELATORIO FINAL =====
set "REPORTFILE=%LOGDIR%\relatorio_%TIMESTAMP%.txt"

(
echo ===============================================================
echo   RELATORIO DE MANUTENCAO DE COMPUTADOR
echo ===============================================================
echo Data/Hora: %date% %time%
echo Computador: %COMPUTERNAME%
echo Usuario: %USERNAME%
echo.
echo ----------------- RESUMO DO SISTEMA -----------------
) > "%REPORTFILE%"

systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" >> "%REPORTFILE%"
echo. >> "%REPORTFILE%"
echo Espaco em disco (unidades): >> "%REPORTFILE%"
wmic logicaldisk get caption,freespace,size >> "%REPORTFILE%"

(
echo.
echo ----------------- LIMPEZA DE TEMPORARIOS -----------------
) >> "%REPORTFILE%"
if defined FREE_BEFORE_MB if defined FREE_AFTER_MB (
    set /a FREED_MB=FREE_AFTER_MB-FREE_BEFORE_MB
    echo Espaco livre antes: !FREE_BEFORE_MB! MB >> "%REPORTFILE%"
    echo Espaco livre depois: !FREE_AFTER_MB! MB >> "%REPORTFILE%"
    echo Espaco liberado nesta sessao: aproximadamente !FREED_MB! MB >> "%REPORTFILE%"
) else (
    echo (Limpeza de temporarios nao foi executada nesta sessao) >> "%REPORTFILE%"
)

(
echo.
echo ----------------- LOG TECNICO COMPLETO -----------------
echo Veja o arquivo de log com todos os detalhes em:
echo %LOGFILE%
echo.
echo ===============================================================
echo   Fim do relatorio
echo ===============================================================
) >> "%REPORTFILE%"

echo.
echo Relatorio salvo em:
echo %REPORTFILE%
echo.
pause
goto :eof

:: =======================================================================
:TUDO
cls
echo ===== EXECUTANDO TODAS AS ROTINAS DE MANUTENCAO =====
echo Isso vai rodar rede, velocidade, sistema, disco, diagnostico,
echo limpeza, cache de navegadores, performance, ponto de restauracao
echo e gerar um relatorio final.
echo No passo de disco, sera pedido a letra da unidade.
echo.
pause
call :RESTAURACAO
call :REDE
call :VELOCIDADE
call :SISTEMA
call :DISCO
call :DIAGNOSTICO
call :LIMPEZA
call :LIMPACACHE
call :PERFORMANCE
call :RELATORIO
cls
echo ===== MANUTENCAO COMPLETA FINALIZADA =====
echo Confira o log em: %LOGFILE%
echo Confira o relatorio em: %REPORTFILE%
pause
goto :eof

:: =======================================================================
:SAIR
cls
echo Log salvo em: %LOGFILE%
echo Encerrando...
timeout /t 2 >nul
endlocal
exit /b
