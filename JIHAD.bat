@echo off
title MENU DO SUPORTE TECNICO - Windows 11 (Dominio)

:: =========================================================
:: MENU PRINCIPAL
:: =========================================================
:menu
cls
echo ========= MENU DO SUPORTE TECNICO =========
echo 0  - Sair
echo 1  - Apagar Temporarios do Usuario (Lentidao)
echo 2  - Limpeza de Disco (cleanmgr)
echo 3  - Resolver Problemas de Audio
echo 4  - Diagnostico de Rede
echo 5  - Disparar Windows Update (StartScan)
echo 6  - Atualizar GPO (gpupdate /force)
echo 7  - Correcao de erros de impressao (submenu)
echo 8  - Reparar Microsoft Teams (classico e novo)
echo 9  - Reparar Google Chrome (cache)
echo 10 - Integridade do SO (DISM + SFC)
echo 11 - Reset completo do Windows Update
echo 12 - Reparar Pilha de Rede (Winsock/IP/DNS/Proxy)
echo 13 - Proxy (mostrar WinHTTP e IE/Edge do usuario)
echo 14 - Sincronizar Hora (NTP)
echo 15 - GPResult (HTML na Area de Trabalho)
echo 16 - SystemInfo consolidado (TXT na Area de Trabalho)
echo 17 - Reset OneDrive
echo 18 - Defender: Atualizar assinatura + Quick Scan
echo 19 - Reparar Microsoft Edge (cache)
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0"  goto sair
if "%opcao%"=="1"  goto lentidao
if "%opcao%"=="2"  goto cleanmgr
if "%opcao%"=="3"  goto audio
if "%opcao%"=="4"  goto rede
if "%opcao%"=="5"  goto windowsupdate
if "%opcao%"=="6"  goto updateGp
if "%opcao%"=="7"  goto impressoras
if "%opcao%"=="8"  goto repararTeams
if "%opcao%"=="9"  goto repararChrome
if "%opcao%"=="10" goto integridadeSO
if "%opcao%"=="11" goto resetWU
if "%opcao%"=="12" goto resetRede
if "%opcao%"=="13" goto proxyInfo
if "%opcao%"=="14" goto hora
if "%opcao%"=="15" goto gpReport
if "%opcao%"=="16" goto sysinfo
if "%opcao%"=="17" goto resetOneDrive
if "%opcao%"=="18" goto defenderQuick
if "%opcao%"=="19" goto repararEdge

echo Opcao invalida.
pause
goto menu

:: =================== FUNCOES ===================

:lentidao
cls
echo Encerrando apps comuns...
taskkill /f /im Teams.exe >nul 2>&1
taskkill /f /im ms-teams.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im outlook.exe >nul 2>&1
timeout /t 1 >nul

echo Limpando TEMP do usuario ativo: %U_TEMP%
for /d %%i in ("%U_TEMP%\*") do rd /s /q "%%i"
del /f /s /q "%U_TEMP%\*.*" >nul 2>&1

echo Limpando cache do Explorer do usuario...
for /d %%i in ("%U_LOCALAPPDATA%\Microsoft\Windows\Explorer\*") do rd /s /q "%%i"
del /f /s /q "%U_LOCALAPPDATA%\Microsoft\Windows\Explorer\*.*" >nul 2>&1

echo [Nota] Prefetch NAO sera apagado (nao recomendado).

echo Concluido. Se a lentidao persistir, rode 'Integridade do SO' (opcao 10).
pause
goto menu

:cleanmgr
cleanmgr
pause
goto menu

:audio
cls
echo Reiniciando servicos de audio...
powershell -NoProfile -Command "Restart-Service -Name 'Audiosrv' -Force; Restart-Service -Name 'AudioEndpointBuilder' -Force"
echo Audio reiniciado. Teste o som.
pause
goto menu

:windowsupdate
cls
echo Disparando verificacao do Windows Update...
if exist "%SystemRoot%\System32\UsoClient.exe" (
  UsoClient StartScan >nul 2>&1
) else (
  wuauclt /resetauthorization /detectnow >nul 2>&1
)
echo Comando enviado ao Windows Update.
pause
goto menu

:updateGp
gpupdate /force
pause
goto menu

:repararTeams
cls
call :log Encerrando Microsoft Teams...
taskkill /f /im Teams.exe >nul 2>&1
taskkill /f /im ms-teams.exe >nul 2>&1
taskkill /f /im Update.exe >nul 2>&1

echo Limpando Teams classico no perfil do usuario...
if exist "%U_APPDATA%\Microsoft\Teams" rd /s /q "%U_APPDATA%\Microsoft\Teams"
if exist "%U_LOCALAPPDATA%\Microsoft\Teams" rd /s /q "%U_LOCALAPPDATA%\Microsoft\Teams"
if exist "%U_LOCALAPPDATA%\SquirrelTemp" rd /s /q "%U_LOCALAPPDATA%\SquirrelTemp"

echo Limpando Novo Teams (MSIX/Store) se presente...
if exist "%U_LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe" rd /s /q "%U_LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe"

echo Teams reparado (usuario: %U_UPN%). Abrir novamente manualmente.
pause
goto menu

:repararChrome
cls
echo Encerrando Google Chrome...
taskkill /f /im chrome.exe >nul 2>&1

echo Limpando (com backup) os caches do Chrome do usuario...
set "CHD=%U_LOCALAPPDATA%\Google\Chrome\User Data\Default"
if exist "%CHD%" (
  ren "%CHD%\Cache" "Cache.bak_%TS%" >nul 2>&1
  ren "%CHD%\Code Cache" "CodeCache.bak_%TS%" >nul 2>&1
  echo Caches renomeados. Se precisar, o backup pode ser removido depois.
) else (
  echo Perfil 'Default' do Chrome nao encontrado em %CHD%
)
pause
goto menu

:repararEdge
cls
echo Encerrando Microsoft Edge...
taskkill /f /im msedge.exe >nul 2>&1

echo Limpando (com backup) os caches do Edge do usuario...
set "ED=%U_LOCALAPPDATA%\Microsoft\Edge\User Data\Default"
if exist "%ED%" (
  ren "%ED%\Cache" "Cache.bak_%TS%" >nul 2>&1
  ren "%ED%\Code Cache" "CodeCache.bak_%TS%" >nul 2>&1
  echo Caches renomeados. Se precisar, o backup pode ser removido depois.
) else (
  echo Perfil 'Default' do Edge nao encontrado em %ED%
)
pause
goto menu

:integridadeSO
cls
echo Executando DISM /RestoreHealth... (isso pode levar varios minutos)
DISM /Online /Cleanup-Image /RestoreHealth >>"%LOG%" 2>&1
echo Executando SFC /scannow...
sfc /scannow >>"%LOG%" 2>&1
echo Integridade do SO verificada. Detalhes no log: %LOG%
pause
goto menu

:resetWU
cls
echo Resetando Windows Update (servicos e pastas). Pressione ENTER para continuar ou Ctrl+C para abortar.
pause
call :log Reset WU: parando servicos...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1

call :log Renomeando SoftwareDistribution e catroot2...
ren "%windir%\SoftwareDistribution" "SoftwareDistribution.bak_%TS%" >nul 2>&1
ren "%windir%\System32\catroot2" "catroot2.bak_%TS%" >nul 2>&1

call :log Iniciando servicos...
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

if exist "%SystemRoot%\System32\UsoClient.exe" (
  UsoClient StartScan >nul 2>&1
) else (
  wuauclt /resetauthorization /detectnow >nul 2>&1
)
echo Reset do Windows Update concluido. Veja %LOG% para detalhes.
pause
goto menu

:resetRede
cls
echo Reset Winsock / IP / DNS / Proxy... (pode exigir reinicio)
netsh winsock reset >>"%LOG%" 2>&1
netsh int ip reset >>"%LOG%" 2>&1
ipconfig /flushdns >>"%LOG%" 2>&1
netsh winhttp reset proxy >>"%LOG%" 2>&1
echo Concluido. Recomenda-se reiniciar a maquina.
pause
goto rede

:proxyInfo
cls
echo Proxy WinHTTP:
netsh winhttp show proxy
echo.
echo Proxy do IE/Edge (usuario atual detectado):
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer
echo Observacao: Quando rodando elevado com credenciais diferentes, as chaves HKCU exibidas podem nao refletir o usuario alvo.
pause
goto rede

:hora
cls
echo Sincronizando hora (NTP)...
w32tm /resync /nowait
echo Status:
w32tm /query /status
pause
goto rede

:gpReport
cls
set "OUT=%USERPROFILE%\Desktop\GPResult_%TS%.html"
echo Gerando GPResult em %OUT% ...
gpresult /h "%OUT%"
if exist "%OUT%" start "" "%OUT%"
pause
goto menu

:sysinfo
cls
set "OUT=%USERPROFILE%\Desktop\SystemInfo_%TS%.txt"
echo Coletando informacoes do sistema em %OUT% ...
systeminfo > "%OUT%"
echo.>>"%OUT%"
echo ==== IPCONFIG /ALL ====>>"%OUT%"
ipconfig /all >> "%OUT%"
echo.>>"%OUT%"
echo ==== ROUTE PRINT ====>>"%OUT%"
route print >> "%OUT%"
start "" notepad "%OUT%"
pause
goto menu

:resetOneDrive
cls
echo Resetando OneDrive do usuario...
taskkill /f /im OneDrive.exe >nul 2>&1
if exist "%U_LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe" (
  "%U_LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe" /reset
  timeout /t 5 >nul
  start "" "%U_LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe"
  echo OneDrive reiniciado para %U_UPN%.
) else (
  echo OneDrive.exe nao encontrado em %U_LOCALAPPDATA%\Microsoft\OneDrive
)
pause
goto menu

:defenderQuick
cls
set "MP=%ProgramFiles%\Windows Defender\MpCmdRun.exe"
if not exist "%MP%" set "MP=%ProgramFiles(x86)%\Windows Defender\MpCmdRun.exe"
if exist "%MP%" (
  echo Atualizando assinatura do Defender...
  "%MP%" -SignatureUpdate >>"%LOG%" 2>&1
  echo Verificacao rapida em andamento...
  "%MP%" -Scan -ScanType 1 >>"%LOG%" 2>&1
  echo Verificacao concluida. Log: %LOG%
) else (
  echo MpCmdRun.exe nao encontrado.
)
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
echo 5 - Reparar Pilha de Rede (Winsock/IP/DNS/Proxy)
echo 6 - Proxy (mostrar)
echo =============================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto ipall
if "%opcao%"=="2" goto flushdns
if "%opcao%"=="3" goto pingserv 
if "%opcao%"=="4" goto rotas
if "%opcao%"=="5" goto resetRede
if "%opcao%"=="6" goto proxyInfo

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
echo 5 - Limpar fila de impressao (PRINTERS)
echo ===========================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto menu
if "%opcao%"=="1" goto erro11b
if "%opcao%"=="2" goto erro0bcb
if "%opcao%"=="3" goto erro709 
if "%opcao%"=="4" goto spooler
if "%opcao%"=="5" goto limparFila

echo Opcao invalida.
pause
goto impressoras
:erro11b
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo Erro 0x0000011b: ajuste aplicado.
pause
goto impressoras

:erro0bcb
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
echo Erro 0x00000bcb: ajuste aplicado.
pause
goto impressoras

:erro709
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
echo Erro 0x00000709: ajuste aplicado.
pause
goto impressoras

:spooler
net stop spooler
timeout /t 2 >nul
net start spooler
echo Spooler reiniciado com sucesso.
pause
goto impressoras

:limparFila
net stop spooler >nul 2>&1
del /q /f "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler >nul 2>&1
echo Fila limpa e spooler reiniciado.
pause
goto impressoras

:sair
call :log ==== Fim do atendimento %DATE% %TIME% ====
exit /b

:: =================== UTILITARIOS ===================

:log
if defined ECHOLOG echo %~1
>>"%LOG%" echo %DATE% %TIME% ^| %~1
exit /b

:detectUserProfile
set "U_UPN="
set "U_SID="
set "U_PROFILE="
for /f "usebackq tokens=* delims=" %%A in (`powershell -NoProfile -Command ^
  "$u=(Get-CimInstance -ClassName Win32_ComputerSystem).UserName; ^
    if(-not $u){ exit 1 }; ^
    $acct=New-Object System.Security.Principal.NTAccount($u); ^
    $sid=$acct.Translate([System.Security.Principal.SecurityIdentifier]).Value; ^
    $prof=(Get-ItemProperty -Path ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\'+$sid) -ErrorAction Stop).ProfileImagePath; ^
    Write-Output ($u+'|'+$sid+'|'+$prof)"`) do (
  for /f "tokens=1-3 delims=|" %%i in ("%%A") do (
    set "U_UPN=%%~i"
    set "U_SID=%%~j"
    set "U_PROFILE=%%~k"
  )
)
if defined U_PROFILE (
  set "U_APPDATA=%U_PROFILE%\AppData\Roaming"
  set "U_LOCALAPPDATA=%U_PROFILE%\AppData\Local"
  set "U_TEMP=%U_LOCALAPPDATA%\Temp"
)
exit /b
