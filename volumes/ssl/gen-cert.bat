@echo off
REM 切換到本檔案所在目錄
cd /d %~dp0

REM 用 Git Bash 執行 openssl 指令
"C:\Program Files\Git\bin\bash.exe" -c "openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout gitlab.key -out gitlab.crt -config openssl.cnf -extensions v3_req"

pause