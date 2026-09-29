@echo off
cd /d "%~dp0exhibition_server"
echo ================================================
echo HELLO, STRANGER - PC C LAN SERVER
echo Starting server on port 8765...
echo ================================================
python hello_stranger_server.py
pause
