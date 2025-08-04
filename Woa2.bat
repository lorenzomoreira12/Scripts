@echo off
title MENU DO SUPORTE TECNICO

:menu
cls
echo ========= MENU DO SUPORTE TECNICO =========
echo 0 - Sair
echo 1 - Apagar Arquivos Temporarios (Lentidao)
echo 2 - Limpeza de Disco
echo 3 - Resolver Problemas de Audio
echo 4 - Diagnostico de Rede
echo 5 - Forcar Windows Update
echo 6 - Atualizar GPO
echo 7 - Processos com maior uso de CPU
echo 8 - Processos com maior uso de RAM
echo 9 - Correcao de erros de impressao
echo 10 - Reparar Microsoft Teams
echo 11 - Reparar Google Chrome
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto lentidao
if "%opcao%"=="2" goto cleanmgr
if "%opcao%"=="3" goto audio
if "%opcao%"=="4" goto rede
if "%opcao%"=="5" goto windowsupdate
if "%opcao%"=="6" goto updateGp
if "%opcao%"=="7" goto cpu
if "%opcao%"=="8" goto ram
if "%opcao%"=="9" goto impressoras
if "%opcao%"=="10" goto repararTeams
if "%opcao%"=="11" goto repararChrome

echo Opcao invalida.
pause
goto menu

:: ================= DIAGNOSTICO DE REDE =================
:rede
cls
echo ============ DIAGNOSTICO DE REDE =============
echo 0 - Voltar para o menu inicial
echo 1 - Verificar informacoes completas da rede
echo 2 - Flush DNS
echo 3 - Ping Servidor
echo 4 - Rotas de rede
echo =============================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto ipall
if "%opcao%"=="2" goto flushdns
if "%opcao%"=="3" goto pingserv 
if "%opcao%"=="4" goto rotas

echo Opcao invalida.
pause
goto rede

:ipall
ipconfig /all
pause
goto rede

:flushdns
ipconfig /flushdns
pause
goto rede

:pingserv
set /p ipNome=Digite o nome ou IP do Servidor:
ping %ipNome%
pause
goto rede

:rotas
route print
pause
goto rede

:: ============== FUNCOES DO MENU PRINCIPAL =================

:lentidao
cls
echo Etapa 1: Abrindo pastas temporarias...
start "" "%temp%"
start "" "%SystemRoot%\SoftwareDistribution\Download"
start "" "%LocalAppData%\Microsoft\Windows\Explorer"
start "" "C:\Windows\Prefetch"

echo.
echo Etapa 2: Executando SFC...
sfc /scannow

echo.
echo Etapa 3: Limpando arquivos temporarios...
del /f /s /q "%temp%\*.*"
del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*.*"
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\*.*"
del /f /s /q "C:\Windows\Prefetch\*.*"

pause
goto menu

:cleanmgr
cleanmgr
pause
goto menu

:audio
cls
echo ========== RESOLUCAO DE PROBLEMAS DE AUDIO ==========
echo Reiniciando os principais servicos de audio...

net stop AudioEndpointBuilder >nul 2>&1
net stop Audiosrv >nul 2>&1
timeout /t 2 >nul
net start Audiosrv >nul 2>&1
net start AudioEndpointBuilder >nul 2>&1

echo.
echo (Opcional) Reiniciando servico Plug and Play...
net stop plugplay >nul 2>&1
timeout /t 2 >nul
net start plugplay >nul 2>&1

echo.
echo Verificando dispositivos de audio...
powershell -Command "Get-PnpDevice -Class Sound" 2>nul

echo.
echo Resolucao de audio concluida. Teste seu som.
pause
goto menu

:windowsupdate
wuauclt /detectnow
echo Comando para forcar atualizacoes executado.
pause
goto menu

:updateGp 
gpupdate /force
pause
goto menu

:cpu
wmic path Win32_PerfFormattedData_PerfProc_Process get Name,PercentProcessorTime | sort
pause
goto menu

:ram
wmic process get name,workingsetsize | sort /r /+2
pause
goto menu

:impressoras
cls
echo =============== IMPRESSORAS ===============
echo 0 - Voltar para o menu inicial
echo 1 - Fix erro 0x0000011b
echo 2 - Fix erro 0x00000bcb
echo 3 - Fix erro 0x00000709
echo 4 - Reiniciar spooler de impressao
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto erro11b
if "%opcao%"=="2" goto erro0bcb
if "%opcao%"=="3" goto erro709 
if "%opcao%"=="4" goto spooler

echo Opcao invalida.
pause
goto impressoras

:erro11b
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo Erro 0x0000011b corrigido.
pause
goto impressoras

:erro0bcb
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
echo Erro 0x00000bcb corrigido.
pause
goto impressoras

:erro709
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
echo Erro 0x00000709 corrigido.
pause
goto impressoras

:spooler
net stop spooler
timeout /t 3 >nul
net start spooler
echo Spooler reiniciado com sucesso.
pause
goto impressoras

:repararTeams
cls
echo Encerrando Microsoft Teams...
taskkill /f /im Teams.exe >nul 2>&1

echo.
echo Limpando cache do Teams...
rmdir /s /q "%AppData%\Microsoft\Teams"
rmdir /s /q "%LocalAppData%\Microsoft\Teams"
rmdir /s /q "%LocalAppData%\SquirrelTemp"
rmdir /s /q "%LocalAppData%\Temp"

echo.
echo Tentando reiniciar o Teams...
start "" "%LocalAppData%\Microsoft\Teams\Update.exe" --processStart "Teams.exe"

echo.
echo Teams reparado e relancado. Aguarde a carga inicial.
pause
goto menu

:repararChrome
cls
echo Encerrando Google Chrome...
taskkill /f /im chrome.exe >nul 2>&1

echo.
echo Limpando cache do Chrome...
rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"

echo.
echo Tentando reiniciar o Chrome...
start chrome

echo.
echo Chrome relancado com sucesso.
pause
goto menu

:sair
exit
