@echo off
cd %~dp0
if exist tmp (
	rmdir /s /q tmp
)
git clone https://github.com/RBBNet/participantes tmp
cp tmp\lab\enodes.md .
rmdir /s /q tmp
