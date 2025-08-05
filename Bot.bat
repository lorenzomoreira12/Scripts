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
echo 7 - Correcao de erros de impressao
echo 8 - Reparar Microsoft Teams
echo 9 - Reparar Google Chrome
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto lentidao
if "%opcao%"=="2" goto cleanmgr
if "%opcao%"=="3" goto audio
if "%opcao%"=="4" goto rede
if "%opcao%"=="5" goto windowsupdate
if "%opcao%"=="6" goto updateGp
if "%opcao%"=="7" goto impressoras
if "%opcao%"=="8" goto repararTeams
if "%opcao%"=="9" goto repararChrome

echo Opcao invalida.
pause
goto menu

:: =================== FUNÇÕES DO MENU PRINCIPAL ===================

:lentidao
cls
echo Etapa 1: Encerrando processos que usam arquivos temporarios...
taskkill /f /im Teams.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im outlook.exe >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 >nul

echo.
echo Etapa 2: Executando SFC...
sfc /scannow

echo.
echo Etapa 3: Limpando arquivos temporarios...

echo Limpando pasta TEMP do usuario...
for /d %%i in ("%temp%\*") do rd /s /q "%%i"
del /f /s /q "%temp%\*.*"

echo Limpando SoftwareDistribution\Download...
for /d %%i in ("%SystemRoot%\SoftwareDistribution\Download\*") do rd /s /q "%%i"
del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*.*"

echo Limpando Explorer cache...
for /d %%i in ("%LocalAppData%\Microsoft\Windows\Explorer\*") do rd /s /q "%%i"
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\*.*"

echo Limpando Prefetch...
for /d %%i in ("C:\Windows\Prefetch\*") do rd /s /q "%%i"
del /f /s /q "C:\Windows\Prefetch\*.*"

echo.
echo Reiniciando o Explorer...
start explorer.exe

echo.
echo Limpeza concluida.
pause
goto menu

:cleanmgr
cleanmgr
pause
goto menu

:audio
cls
echo ========== RESOLUCAO DE PROBLEMAS DE AUDIO ==========
echo Reiniciando servicos principais de audio...

powershell -Command "Restart-Service -Name 'Audiosrv' -Force"
powershell -Command "Restart-Service -Name 'AudioEndpointBuilder' -Force"

echo.
echo Audio reiniciado. Teste o som do sistema.
pause
goto menu

:windowsupdate
cls
echo Forcando o Windows Update a buscar e instalar atualizacoes...

powershell -Command "UsoClient StartScan; UsoClient StartDownload; UsoClient StartInstall"

echo.
echo Comando de atualizacao enviado. Verifique o Windows Update em alguns minutos.
pause
goto menu

:repararTeams
cls
echo Encerrando Microsoft Teams...
taskkill /f /im Teams.exe >nul 2>&1
taskkill /f /im Update.exe >nul 2>&1

echo.
echo Limpando cache e arquivos temporarios do Teams...
rd /s /q "%AppData%\Microsoft\Teams"
rd /s /q "%LocalAppData%\Microsoft\Teams"
rd /s /q "%LocalAppData%\SquirrelTemp"
rd /s /q "%LocalAppData%\Temp"

echo.
echo Microsoft Teams reparado. Abra novamente manualmente.
pause
goto menu

:repararChrome
cls
echo Encerrando Google Chrome...
taskkill /f /im chrome.exe >nul 2>&1

echo.
echo Limpando cache do Chrome...
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"

echo.
echo Chrome reparado. Reabra o navegador se necessario.
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

:: ================= IMPRESSORAS =================

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

:sair
exit
