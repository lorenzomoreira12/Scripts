@echo off
title MENU DO SUPORTE TECNICO

:menu
cls
echo ========= MENU DO SUPORTE TECNICO =========
echo 0 - Sair
echo 1 - Rede 
echo 2 - Impressoras 
echo 3 - Sistema 
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto rede 
if "%opcao%"=="2" goto impressoras
if "%opcao%"=="3" goto sistema

echo Opcao invalida.
pause
goto menu

:: ==================== REDE ====================
:rede
cls
echo ================== REDE ==================
echo 0 - Voltar para o menu inicial
echo 1 - Verificar informacoes completas da rede
echo 2 - Flush DNS
echo 3 - Ping Servidor
echo 4 - Rotas de rede
echo ===========================================
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

:: ================= IMPRESSORAS ================
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

:: ================== SISTEMA ====================
:sistema
cls
echo ================= SISTEMA =================
echo 0 - Voltar para o menu inicial
echo 1 - Lentidao (SFC + limpeza)
echo 2 - Atualizar Group Policy
echo 3 - Forcar Windows Update
echo 4 - Processos com maior uso de CPU
echo 5 - Processos com maior uso de RAM
echo 6 - Limpeza de Disco
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto lentidao
if "%opcao%"=="2" goto updateGp 
if "%opcao%"=="3" goto windowsupdate
if "%opcao%"=="4" goto cpu 
if "%opcao%"=="5" goto ram
if "%opcao%"=="6" goto cleanmgr

echo Opcao invalida.
pause
goto sistema

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
goto sistema

:updateGp 
gpupdate /force
pause
goto sistema

:windowsupdate
wuauclt /detectnow
echo Comando para forcar atualizacoes executado.
pause
goto sistema

:cpu
wmic path Win32_PerfFormattedData_PerfProc_Process get Name,PercentProcessorTime | sort
pause
goto sistema

:ram
wmic process get name,workingsetsize | sort /r /+2
pause
goto sistema

:cleanmgr
cleanmgr
pause
goto sistema

:sair
exit
